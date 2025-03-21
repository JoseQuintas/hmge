/*
   MINIGUI - Harbour Win32 GUI library source code

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
    Copyright 1999-2025, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2021 Alexander S.Kresin <alex@kresin.ru>

   Parts  of  this  code  is contributed and used here under permission of his
   author: Copyright 2016 (C) P.Chornyj <myorg63@mail.ru>
 */
#include <mgdefs.h>

#if defined( __WATCOMC__ )
#ifndef _RSIZE_T_DEFINED
#define _RSIZE_T_DEFINED
typedef size_t       rsize_t;
#endif
_WCRTLINK extern int swprintf_s( wchar_t * __restrict __s, rsize_t __n, const wchar_t * __restrict __format, ... );
#endif
extern HB_SIZE       hmg_tstrlen( const TCHAR *pText );

void hmg_ErrorExit( LPCTSTR lpszMessage, DWORD dwError, BOOL bExit )
{
   LPVOID   lpMsgBuf = NULL;
   LPVOID   lpDisplayBuf = NULL;
   DWORD    nError = ( dwError != 0 ) ? dwError : GetLastError();

   if
   (
      FormatMessage
         (
            FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL,
            nError,
            MAKELANGID( LANG_NEUTRAL, SUBLANG_DEFAULT ),
            ( LPTSTR ) &lpMsgBuf,
            0,
            NULL
         )
   )
   {
      // Only proceed if lpMsgBuf was successfully allocated
      size_t   displayBufSize = ( hmg_tstrlen( ( LPCTSTR ) lpMsgBuf ) + hmg_tstrlen( lpszMessage ) + 40 ) * sizeof( TCHAR );
      lpDisplayBuf = ( LPVOID ) LocalAlloc( LMEM_ZEROINIT, displayBufSize );

      if( lpDisplayBuf )
      {
         // Format the combined error message
   #ifdef UNICODE
      #if defined( __BORLANDC__ ) && ( __BORLANDC__ <= 1410 )
         swprintf( ( LPTSTR ) lpDisplayBuf, TEXT( "'%s' failed with error %lu: %s" ), lpszMessage, nError, ( LPTSTR ) lpMsgBuf );
      #else
         swprintf_s
         (
            ( LPTSTR ) lpDisplayBuf,
            LocalSize( lpDisplayBuf ) / sizeof( TCHAR ),
            TEXT( "'%s' failed with error %lu: %s" ),
            lpszMessage,
            nError,
            ( LPTSTR ) lpMsgBuf
         );
      #endif
   #else
         hb_snprintf
         (
            ( LPTSTR ) lpDisplayBuf,
            LocalSize( lpDisplayBuf ) / sizeof( TCHAR ),
            TEXT( "'%s' failed with error %lu: %s" ),
            lpszMessage,
            nError,
            ( LPTSTR ) lpMsgBuf
         );
   #endif

         // Show the formatted error message
         MessageBox( NULL, ( LPCTSTR ) lpDisplayBuf, TEXT( "MiniGUI Error" ), MB_OK );
      }
   }

   // Clean up allocated memory
   if( lpMsgBuf )
   {
      LocalFree( lpMsgBuf );
   }

   if( lpDisplayBuf )
   {
      LocalFree( lpDisplayBuf );
   }

   // Exit process if specified
   if( bExit )
   {
      ExitProcess( nError );
   }
}
