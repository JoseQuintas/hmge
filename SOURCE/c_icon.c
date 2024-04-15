/* MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   This    program  is  free  software;  you can redistribute it and/or modify
   it under  the  terms  of the GNU General Public License as published by the
   Free  Software   Foundation;  either  version 2 of the License, or (at your
   option) any later version.

   This   program   is   distributed  in  the hope that it will be useful, but
   WITHOUT    ANY    WARRANTY;    without   even   the   implied  warranty  of
   MERCHANTABILITY  or  FITNESS  FOR A PARTICULAR PURPOSE. See the GNU General
   Public License for more details.

   You   should  have  received a copy of the GNU General Public License along
   with   this   software;   see  the  file COPYING. If not, write to the Free
   Software   Foundation,   Inc.,   59  Temple  Place,  Suite  330, Boston, MA
   02111-1307 USA (or visit the web site http://www.gnu.org/).

   As   a   special  exception, you have permission for additional uses of the
   text  contained  in  this  release  of  Harbour Minigui.

   The   exception   is that,   if   you  link  the  Harbour  Minigui  library
   with  other    files   to  produce   an   executable,   this  does  not  by
   itself   cause  the   resulting   executable    to   be  covered by the GNU
   General  Public  License.  Your    use  of that   executable   is   in   no
   way  restricted on account of linking the Harbour-Minigui library code into
   it.

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

   Parts  of  this  code  is contributed and used here under permission of his
   author: Copyright 2016 (C) P.Chornyj <myorg63@mail.ru>
 */
#include <mgdefs.h>

#include <shellapi.h>

#ifdef UNICODE
LPWSTR      AnsiToWide( LPCSTR );
#endif
HINSTANCE   GetInstance( void );
HINSTANCE   GetResources( void );

// Minigui Resources control system
void        RegisterResource( HANDLE hResource, LPCSTR szType );
void pascal DelResource( HANDLE hResource );

// HICON WINAPI CopyIcon( HICON hIcon )
HB_FUNC( COPYICON )
{
   HICON hIcon;

   hIcon = CopyIcon( hmg_par_raw_HICON( 1 ) );

   RegisterResource( hIcon, "ICON" );
   hmg_ret_raw_HANDLE( hIcon );
}

// BOOL WINAPI DestroyIcon( HICON hIcon )
HB_FUNC( DESTROYICON )
{
   HICON hIcon = hmg_par_raw_HICON( 1 );

   DelResource( hIcon );
   hb_retl( DestroyIcon( hIcon ) );
}

// HICON WINAPI DuplicateIcon( HINSTANCE hInst, HICON hIcon )
HB_FUNC( DUPLICATEICON )
{
   HICON hIcon;

   hIcon = DuplicateIcon( ( HINSTANCE ) NULL, hmg_par_raw_HICON( 1 ) );

   RegisterResource( hIcon, "ICON" );
   hmg_ret_raw_HANDLE( hIcon );
}

// HICON LoadIcon( HINSTANCE hInstance, LPCTSTR lpIconName )
HB_FUNC( LOADICON )
{
   HINSTANCE   hinstance = ( HB_ISNIL( 1 ) ? NULL : hmg_par_raw_HINSTANCE( 1 ) );
   HICON       hIcon;

#ifndef UNICODE
   hIcon = LoadIcon( hinstance, HB_ISCHAR( 2 ) ? hb_parc( 2 ) : MAKEINTRESOURCE( hb_parni( 2 ) ) );
#else
   LPWSTR   pW = AnsiToWide( ( char * ) hb_parc( 2 ) );
   hIcon = LoadIcon( hinstance, HB_ISCHAR( 2 ) ? pW : ( LPCWSTR ) MAKEINTRESOURCE( hb_parni( 2 ) ) );
#endif
   RegisterResource( hIcon, "ICON" );
   hmg_ret_raw_HANDLE( hIcon );

#ifdef UNICODE
   hb_xfree( pW );
#endif
}

// HICON ExtractIcon( HINSTANCE hInst, LPCTSTR lpszExeFileName, UINT nIconIndex )
HB_FUNC( EXTRACTICON )
{
#ifndef UNICODE
   char     *lpFileName = ( char * ) hb_parc( 1 );
#else
   LPWSTR   lpFileName = AnsiToWide( ( char * ) hb_parc( 1 ) );
#endif
   int      nIconIndex = hmg_par_INT( 2 );

   if( nIconIndex == -1 )
   {
      hmg_ret_raw_HANDLE( ExtractIcon( GetInstance(), lpFileName, nIconIndex ) );
   }
   else
   {
      HICON hIcon;

      hIcon = ExtractIcon( GetInstance(), lpFileName, nIconIndex );
      RegisterResource( hIcon, "ICON" );
      hmg_ret_raw_HANDLE( hIcon );
   }

#ifdef UNICODE
   hb_xfree( lpFileName );
#endif
}

// UINT ExtractIconEx( LPCTSTR lpszFile, int nIconIndex, int cxIcon, int cyIcon )
HB_FUNC( EXTRACTICONEX )
{
#ifndef UNICODE
   char     *lpFileName = ( char * ) hb_parc( 1 );
#else
   LPWSTR   lpFileName = AnsiToWide( ( char * ) hb_parc( 1 ) );
#endif
   int      nIconIndex = hb_parni( 2 );

   if( nIconIndex == -1 )
   {
#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 )
      hmg_ret_UINT( ExtractIconEx( lpFileName, nIconIndex, NULL, NULL, 0 ) );
#else
      hmg_ret_UINT( PrivateExtractIcons( lpFileName, nIconIndex, 0, 0, NULL, NULL, 0, 0 ) );
#endif
   }
   else
   {
      HICON hIcon;
#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 )
      UINT  nIconId = 0;

      // UINT ExtractIconExA(LPCSTR lpszFile, int nIconIndex, HICON *phiconLarge, HICON *phiconSmall, UINT nIcons)
      UINT  nIconCount = ExtractIconEx( lpFileName, nIconIndex, &hIcon, NULL, 1 );
#else
      UINT  nIconId;
      int   cx = hb_parnidef( 3, GetSystemMetrics( SM_CXICON ) );
      int   cy = hb_parnidef( 4, GetSystemMetrics( SM_CYICON ) );

      // UINT PrivateExtractIcons( LPCTSTR lpszFile, int nIconIndex, int cxIcon, int cyIcon, HICON *phicon, UINT *piconid, UINT nIcons, UINT flags )
      UINT  nIconCount = PrivateExtractIcons( lpFileName, nIconIndex, cx, cy, &hIcon, &nIconId, 1, 0 );
#endif
      if( nIconCount > 0 )
      {
         hb_reta( 2 );

         RegisterResource( hIcon, "ICON" );
         hmg_storvnl_HANDLE( hIcon, -1, 1 );
         HB_STORNI( nIconId, -1, 2 );
      }
   }

#ifdef UNICODE
   hb_xfree( lpFileName );
#endif
}

// IsHIcon( hIcon ) --> lIsHIcon
HB_FUNC( ISHICON )
{
   ICONINFO iconinfo;
   BOOL     bTrue;

   bTrue = GetIconInfo( hmg_par_raw_HICON( 1 ), &iconinfo );

   if( bTrue )
   {
      bTrue = iconinfo.fIcon;

      if( iconinfo.hbmMask )
      {
         DeleteObject( iconinfo.hbmMask );
      }

      if( iconinfo.hbmColor )
      {
         DeleteObject( iconinfo.hbmColor );
      }
   }

   hb_retl( bTrue );
}

HB_FUNC( LOADICONBYNAME )
{
   HICON hIcon = NULL;

   if( hb_parclen( 1 ) > 0 )
   {
#ifndef UNICODE
      const char  *pszResOrFile = hb_parc( 1 );
#else
      LPCWSTR     pszResOrFile = AnsiToWide( ( char * ) hb_parc( 1 ) );
#endif
      int         cxDesired = hb_parni( 2 );
      int         cyDesired = hb_parni( 3 );
      HINSTANCE   hInstance = HB_ISNIL( 4 ) ? GetResources() : hmg_par_raw_HINSTANCE( 4 );

      hIcon = ( HICON ) LoadImage( hInstance, pszResOrFile, IMAGE_ICON, cxDesired, cyDesired, LR_DEFAULTCOLOR );

      if( hIcon == NULL )
      {
         hIcon = ( HICON ) LoadImage( 0, pszResOrFile, IMAGE_ICON, cxDesired, cyDesired, LR_LOADFROMFILE | LR_DEFAULTCOLOR );
      }

      if( hIcon != NULL )
      {
         RegisterResource( hIcon, "ICON" );
      }

#ifdef UNICODE
      hb_xfree( ( TCHAR * ) pszResOrFile );
#endif
   }

   hmg_ret_raw_HANDLE( hIcon );
}

HB_FUNC( DRAWICONEX )
{
   HWND  hwnd = hmg_par_raw_HWND( 1 );

   if( IsWindow( hwnd ) )
   {
      HICON    hIcon = hmg_par_raw_HICON( 4 );
      HDC      hdc = GetDC( hwnd );
      HBRUSH   hbrFlickerFreeDraw = CreateSolidBrush( hmg_par_COLORREF( 7 ) );

      hb_retl( DrawIconEx( hdc, hb_parni( 2 ), hb_parni( 3 ), hIcon, hb_parni( 5 ), hb_parni( 6 ), 0, hbrFlickerFreeDraw, DI_NORMAL ) );

      DeleteObject( hbrFlickerFreeDraw );

      if( hb_parldef( 8, HB_TRUE ) )
      {
         DelResource( hIcon );
         DestroyIcon( hIcon );
      }

      ReleaseDC( hwnd, hdc );
   }
}
