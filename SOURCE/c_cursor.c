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

/*
   File:           c_cursor.c
   Contributors:   Jacek Kubica <kubica@wssk.wroc.pl>
                   Grigory Filatov <gfilatov@gmail.com>
   Description:    Mouse Cursor Shapes handling for MiniGUI
   Status:         Public Domain
 */
#include <mgdefs.h>

#ifdef UNICODE
LPWSTR      AnsiToWide( LPCSTR );
#endif
HINSTANCE   GetInstance( void );
HINSTANCE   GetResources( void );

HB_FUNC( LOADCURSOR )
{
   HINSTANCE   hInstance = HB_ISNIL( 1 ) ? NULL : hmg_par_raw_HINSTANCE( 1 );

#ifndef UNICODE
   LPCSTR      lpCursorName = ( hb_parinfo( 2 ) & HB_IT_STRING ) ? hb_parc( 2 ) : MAKEINTRESOURCE( hb_parni( 2 ) );
   hmg_ret_raw_HANDLE( LoadCursor( hInstance, lpCursorName ) );
#else
   LPWSTR   pW = AnsiToWide( ( char * ) hb_parc( 2 ) );
   LPCWSTR  lpCursorName = HB_ISCHAR( 2 ) ? pW : ( LPCWSTR ) MAKEINTRESOURCE( hb_parni( 2 ) );

   hmg_ret_raw_HANDLE( LoadCursor( hInstance, lpCursorName ) );
   hb_xfree( pW );
#endif
}

HB_FUNC( LOADCURSORFROMFILE )
{
#ifndef UNICODE
   hmg_ret_raw_HANDLE( LoadCursorFromFile( ( LPCSTR ) hb_parc( 1 ) ) );
#else
   LPCWSTR  lpFileName = AnsiToWide( ( char * ) hb_parc( 1 ) );
   hmg_ret_raw_HANDLE( LoadCursorFromFile( lpFileName ) );
   hb_xfree( ( TCHAR * ) lpFileName );
#endif
}

HB_FUNC( SETRESCURSOR )
{
   hmg_ret_raw_HANDLE( SetCursor( hmg_par_raw_HCURSOR( 1 ) ) );
}

HB_FUNC( FILECURSOR )
{
#ifndef UNICODE
   hmg_ret_raw_HANDLE( SetCursor( LoadCursorFromFile( ( LPCSTR ) hb_parc( 1 ) ) ) );
#else
   LPCWSTR  lpFileName = AnsiToWide( ( char * ) hb_parc( 1 ) );
   hmg_ret_raw_HANDLE( SetCursor( LoadCursorFromFile( lpFileName ) ) );
   hb_xfree( ( TCHAR * ) lpFileName );
#endif
}

HB_FUNC( CURSORHAND )
{
#if ( WINVER >= 0x0500 )
   hmg_ret_raw_HANDLE( SetCursor( LoadCursor( NULL, IDC_HAND ) ) );
#else
   hmg_ret_raw_HANDLE( SetCursor( LoadCursor( GetInstance(), TEXT( "MINIGUI_FINGER" ) ) ) );
#endif
}

HB_FUNC( SETWINDOWCURSOR )
{
   HCURSOR  ch;

#ifndef UNICODE
   LPCSTR   lpCursorName = ( hb_parinfo( 2 ) & HB_IT_STRING ) ? hb_parc( 2 ) : MAKEINTRESOURCE( hb_parni( 2 ) );
#else
   LPWSTR   pW = AnsiToWide( ( char * ) hb_parc( 2 ) );
   LPCWSTR  lpCursorName = HB_ISCHAR( 2 ) ? pW : ( LPCWSTR ) MAKEINTRESOURCE( hb_parni( 2 ) );
#endif
   ch = LoadCursor( ( HB_ISCHAR( 2 ) ) ? GetResources() : NULL, lpCursorName );

   if( ( ch == NULL ) && HB_ISCHAR( 2 ) )
   {
      ch = LoadCursorFromFile( lpCursorName );
   }

   if( ch != NULL )
   {
      SetClassLongPtr( hmg_par_raw_HWND( 1 ), // window handle
      GCLP_HCURSOR, // change cursor
      ( LONG_PTR ) ch );  // new cursor
   }

#ifdef UNICODE
   hb_xfree( pW );
#endif
}

HB_FUNC( SETHANDCURSOR )
{
#if ( WINVER >= 0x0500 )
   SetClassLongPtr( hmg_par_raw_HWND( 1 ), GCLP_HCURSOR, ( LONG_PTR ) LoadCursor( NULL, IDC_HAND ) );
#else
   SetClassLongPtr( hmg_par_raw_HWND( 1 ), GCLP_HCURSOR, ( LONG_PTR ) LoadCursor( GetInstance(), TEXT( "MINIGUI_FINGER" ) ) );
#endif
}
