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
#include <mgdefs.h>

#include <commctrl.h>
#if defined( _MSC_VER )
#pragma warning( push )
#pragma warning( disable : 4201 )
#endif
#include <richedit.h>
#if defined( _MSC_VER )
#pragma warning( pop )
#endif
#if defined( __MINGW32__ ) && defined( __MINGW32_VERSION )
#define IMF_AUTOFONT 0x0002
#endif
#if defined( __WATCOMC__ )
#define ENM_DRAGDROPDONE   0x00000010
#define SF_USECODEPAGE     0x0020   /* CodePage given by high word */
#endif
#if defined( MSFTEDIT_CLASS )
#undef MSFTEDIT_CLASS
#endif
#define MSFTEDIT_CLASS  TEXT( "RICHEDIT50W" )

static BOOL       IsWinxpSp1Min( void );

#ifdef UNICODE
LPWSTR            AnsiToWide( LPCSTR );
LPSTR             WideToAnsi( LPWSTR );
#endif
HINSTANCE         GetInstance( void );

static HINSTANCE  hRELib = NULL;

HB_FUNC( INITRICHEDITBOX )
{
   HWND  hRE = NULL;
   TCHAR *lpClassName;
   DWORD Style = ES_MULTILINE | ES_WANTRETURN | WS_CHILD | ES_NOHIDESEL | ( hb_parl( 14 ) ? ES_AUTOVSCROLL : WS_VSCROLL );

   if( hb_parl( 10 ) )
   {
      Style |= ES_READONLY;
   }

   if( !hb_parl( 11 ) )
   {
      Style |= WS_VISIBLE;
   }

   if( !hb_parl( 12 ) )
   {
      Style |= WS_TABSTOP;
   }

   if( !hb_parl( 13 ) )
   {
      Style |= WS_HSCROLL;
   }

   if( IsWinxpSp1Min() )
   {
      if( !hRELib )
      {
         hRELib = LoadLibrary( TEXT( "Msftedit.dll" ) );
      }

      lpClassName = MSFTEDIT_CLASS;
   }
   else
   {
      if( !hRELib )
      {
         hRELib = LoadLibrary( TEXT( "RichEd20.dll" ) );
      }

      lpClassName = RICHEDIT_CLASS;
   }

   if( hRELib )
   {
      hRE = CreateWindowEx
         (
            WS_EX_CLIENTEDGE,
            lpClassName,
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

      SendMessage( hRE, EM_EXLIMITTEXT, ( WPARAM ) hb_parni( 9 ), ( LPARAM ) 0 );
      SendMessage( hRE, EM_SETEVENTMASK, ( WPARAM ) 0, ( LPARAM ) ENM_SELCHANGE | ENM_DRAGDROPDONE | ENM_CHANGE | ENM_SCROLL );
   }

   hmg_ret_raw_HWND( hRE );
}

HB_FUNC( UNLOADRICHEDITLIB )
{
   if( hRELib )
   {
      FreeLibrary( hRELib );
      hRELib = NULL;
   }
}

DWORD CALLBACK EditStreamCallbackR( DWORD_PTR dwCookie, LPBYTE lpbBuff, LONG cb, LONG FAR *pcb )
{
   HANDLE   hFile = ( HANDLE ) dwCookie;

   if( !ReadFile( hFile, ( LPVOID ) lpbBuff, cb, ( LPDWORD ) pcb, NULL ) )
   {
      return( DWORD ) - 1;
   }

   return 0;
}

DWORD CALLBACK EditStreamCallbackW( DWORD_PTR dwCookie, LPBYTE lpbBuff, LONG cb, LONG FAR *pcb )
{
   HANDLE   hFile = ( HANDLE ) dwCookie;

   if( !WriteFile( hFile, ( LPVOID ) lpbBuff, cb, ( LPDWORD ) pcb, NULL ) )
   {
      return( DWORD ) - 1;
   }

   return 0;
}

HB_FUNC( STREAMIN )                 //StreamIn(HWND hwndCtrl, LPCTSTR lpszPath, int typ )
{
   HWND        hwnd = hmg_par_raw_HWND( 1 );
   HANDLE      hFile;

#ifndef UNICODE
   LPCSTR      cFileName = ( char * ) hb_parc( 2 );
#else
   LPCWSTR     cFileName = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   EDITSTREAM  es;
   long        Flag, Mode;

   switch( hb_parni( 3 ) )
   {
      case 1:
         Flag = SF_TEXT;
         Mode = TM_PLAINTEXT;
         break;

      case 2:
         Flag = SF_RTF;
         Mode = TM_RICHTEXT;
         break;

      case 3:
         Flag = SF_TEXT | SF_UNICODE;
         Mode = TM_PLAINTEXT;
         break;

      case 4:
         Flag = ( CP_UTF8 << 16 ) | SF_USECODEPAGE | SF_TEXT;
         Mode = TM_PLAINTEXT;
         break;

      case 5:
         Flag = ( CP_UTF8 << 16 ) | SF_USECODEPAGE | SF_RTF;
         Mode = TM_RICHTEXT;
         break;

      case 6:
         Flag = ( CP_UTF7 << 16 ) | SF_USECODEPAGE | SF_TEXT;
         Mode = TM_PLAINTEXT;
         break;

      default:
         Flag = SF_TEXT;
         Mode = TM_PLAINTEXT;
   }

   // open the source file.
   if( ( hFile = CreateFile( cFileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL ) ) == INVALID_HANDLE_VALUE )
   {
      hb_retl( FALSE );
      return;
   }

#ifdef UNICODE
   else
   {
      hb_xfree( ( TCHAR * ) cFileName );
   }
#endif
   es.pfnCallback = EditStreamCallbackR;
   es.dwCookie = ( DWORD_PTR ) hFile;
   es.dwError = 0;

   // send EM_STREAMIN message to the Rich Edit Control.
   SendMessage( hwnd, EM_STREAMIN, ( WPARAM ) Flag, ( LPARAM ) & es );
   SendMessage( hwnd, EM_SETTEXTMODE, ( WPARAM ) Mode, 0 );

   CloseHandle( hFile );

   hmg_ret_L( !( es.dwError ) );
}

HB_FUNC( STREAMOUT )                //StreamOut(HWND hwndCtrl, LPCTSTR lpszPath, int Typ )
{
   HWND        hwnd = hmg_par_raw_HWND( 1 );
   HANDLE      hFile;

#ifndef UNICODE
   LPCSTR      cFileName = ( char * ) hb_parc( 2 );
#else
   LPCWSTR     cFileName = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   EDITSTREAM  es;
   long        Flag;

   switch( hb_parni( 3 ) )
   {
      case 1:
         Flag = SF_TEXT;
         break;

      case 2:
         Flag = SF_RTF;
         break;

      case 3:
         Flag = SF_TEXT | SF_UNICODE;
         break;

      case 4:
         Flag = ( CP_UTF8 << 16 ) | SF_USECODEPAGE | SF_TEXT;
         break;

      case 5:
         Flag = ( CP_UTF8 << 16 ) | SF_USECODEPAGE | SF_RTF;
         break;

      case 6:
         Flag = ( CP_UTF7 << 16 ) | SF_USECODEPAGE | SF_TEXT;
         break;

      default:
         Flag = SF_TEXT;
   }

   // open the destination file.
   if( ( hFile = CreateFile( cFileName, GENERIC_WRITE, FILE_SHARE_WRITE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL ) ) == INVALID_HANDLE_VALUE )
   {
      hb_retl( FALSE );
      return;
   }

#ifdef UNICODE
   else
   {
      hb_xfree( ( TCHAR * ) cFileName );
   }
#endif
   es.pfnCallback = EditStreamCallbackW;
   es.dwCookie = ( DWORD_PTR ) hFile;
   es.dwError = 0;

   // send EM_STREAMOUT message to the Rich Edit Control.
   SendMessage( hwnd, EM_STREAMOUT, ( WPARAM ) Flag, ( LPARAM ) & es );

   CloseHandle( hFile );

   hmg_ret_L( !( es.dwError ) );
}

HB_FUNC( GETAUTOFONTRTF )           // GetAutoFont(HWND hwnd)
{
   LRESULT  lAuto;

   lAuto = SendMessage( hmg_par_raw_HWND( 1 ), EM_GETLANGOPTIONS, 0, 0 ) & IMF_AUTOFONT;

   hmg_ret_L( lAuto );
}

HB_FUNC( SETAUTOFONTRTF )           // SetAutoFont(HWND hwnd, lAutoFont)
{
   HWND     hwnd = hmg_par_raw_HWND( 1 );
   LRESULT  lOpt, lResult;

   lOpt = SendMessage( hwnd, EM_GETLANGOPTIONS, 0, 0 );

   if( hb_parl( 2 ) )
   {
      lOpt &= IMF_AUTOFONT;
   }
   else
   {
      lOpt &= ~IMF_AUTOFONT;
   }

   lResult = SendMessage( hwnd, EM_SETLANGOPTIONS, 0, lOpt );

   hmg_ret_L( lResult );
}

HB_FUNC( SETBKGNDCOLOR )            // SetBkgndColor(HWND hwnd, lSyscol, nRed, nGreen, nBlue)
{
   LRESULT  lResult;
   INT      syscol = hb_parl( 2 ) ? 0 : 1;
   COLORREF bkgcolor = RGB( hb_parni( 3 ), hb_parni( 4 ), hb_parni( 5 ) );

   lResult = SendMessage( hmg_par_raw_HWND( 1 ), EM_SETBKGNDCOLOR, ( WPARAM ) syscol, ( LPARAM ) bkgcolor );

   hmg_ret_L( lResult );
}

HB_FUNC( GETFONTRTF )
{
   CHARFORMAT  cF;
   long        PointSize;
   int         bold;
   int         Italic;
   int         Underline;
   int         StrikeOut;
   int         SelText;

#ifdef UNICODE
   LPSTR       pStr;
#endif
   cF.cbSize = sizeof( CHARFORMAT );
   cF.dwMask = CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE | CFM_SIZE;
   if( hb_parni( 2 ) > 0 )
   {
      SelText = SCF_SELECTION;
   }
   else
   {
      SelText = SCF_DEFAULT;
   }

   SendMessage( hmg_par_raw_HWND( 1 ), EM_GETCHARFORMAT, ( WPARAM ) SelText, ( LPARAM ) &cF );

   PointSize = cF.yHeight / 20;

   bold = ( cF.dwEffects & CFE_BOLD ) ? 1 : 0;
   Italic = ( cF.dwEffects & CFE_ITALIC ) ? 1 : 0;
   Underline = ( cF.dwEffects & CFE_UNDERLINE ) ? 1 : 0;
   StrikeOut = ( cF.dwEffects & CFE_STRIKEOUT ) ? 1 : 0;

   hb_reta( 8 );
#ifndef UNICODE
   HB_STORC( cF.szFaceName, -1, 1 );
#else
   pStr = WideToAnsi( cF.szFaceName );
   HB_STORC( pStr, -1, 1 );
   hb_xfree( pStr );
#endif
   HB_STORVNL( ( LONG ) PointSize, -1, 2 );
   HB_STORL( bold, -1, 3 );
   HB_STORL( Italic, -1, 4 );
   HB_STORVNL( cF.crTextColor, -1, 5 );
   HB_STORL( Underline, -1, 6 );
   HB_STORL( StrikeOut, -1, 7 );
   HB_STORNI( cF.bCharSet, -1, 8 );
}

HB_FUNC( SETFONTRTF )
{
   LRESULT     lResult;
   CHARFORMAT  cF;
   DWORD       Mask;
   DWORD       Effects = 0;
   int         SelText = SCF_SELECTION;

#ifndef UNICODE
   TCHAR       *szFaceName = ( TCHAR * ) hb_parc( 3 );
#else
   TCHAR       *szFaceName = ( TCHAR * ) hb_osStrU16Encode( ( char * ) hb_parc( 3 ) );
#endif
   cF.cbSize = sizeof( CHARFORMAT );

   Mask = ( DWORD ) SendMessage( hmg_par_raw_HWND( 1 ), EM_GETCHARFORMAT, ( WPARAM ) SelText, ( LPARAM ) &cF );

   if( hb_parni( 10 ) > 0 )
   {
      Mask = hb_parni( 10 );
   }

   if( hb_parni( 2 ) < 0 )
   {
      SelText = SCF_ALL;
   }
   else if( hb_parni( 2 ) > 0 )
   {
      SelText = SCF_SELECTION | SCF_WORD;
   }

   if( hb_parl( 5 ) )
   {
      Effects |= CFE_BOLD;
   }

   if( hb_parl( 6 ) )
   {
      Effects |= CFE_ITALIC;
   }

   if( hb_parl( 8 ) )
   {
      Effects |= CFE_UNDERLINE;
   }

   if( hb_parl( 9 ) )
   {
      Effects |= CFE_STRIKEOUT;
   }

   cF.dwMask = Mask;
   cF.dwEffects = Effects;

   if( hb_parnl( 4 ) )
   {
      cF.yHeight = hb_parnl( 4 ) * 20;
   }

   cF.crTextColor = hmg_par_COLORREF( 7 );

   if( hb_parclen( 3 ) > 0 )
   {
      lstrcpy( cF.szFaceName, szFaceName );
   }

   lResult = SendMessage( hmg_par_raw_HWND( 1 ), EM_SETCHARFORMAT, ( WPARAM ) SelText, ( LPARAM ) &cF );

   hmg_ret_L( lResult );
}

#if defined( _MSC_VER )
#pragma warning( disable : 4996 )
#endif
static BOOL IsWinxpSp1Min( void )
{
#ifndef UNICODE
   LPCSTR         pch;
#else
   LPCWSTR        pch;
#endif
   OSVERSIONINFO  osvi;

   osvi.dwOSVersionInfoSize = sizeof( osvi );

   if( !GetVersionEx( &osvi ) )
   {
      return FALSE;
   }

   if( osvi.dwMajorVersion >= 5 )
   {
      if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 0 )
      {
         return FALSE;
      }
      else if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 1 )
      {
#ifndef UNICODE
         pch = strstr( osvi.szCSDVersion, "Service Pack" );
#else
         pch = _tcsstr( osvi.szCSDVersion, TEXT( "Service Pack" ) );
#endif
         if( lstrcmpi( pch, TEXT( "Service Pack 1" ) ) >= 0 )
         {
            return TRUE;
         }
         else
         {
            return FALSE;
         }
      }

      return TRUE;
   }

   return FALSE;
}
