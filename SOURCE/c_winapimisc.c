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
    Copyright 1999-2025, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2021 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/
#include <mgdefs.h>

#if defined( _MSC_VER )
#pragma warning( disable : 4996 )
#endif
#include <commctrl.h>
#include <lmcons.h>
#include <shellapi.h>
#include <shlobj.h>
#include <shlwapi.h>

#include "hbapierr.h"
#include "hbapiitm.h"

#if defined( __XHARBOUR__ ) || ( __HARBOUR__ - 0 < 0x030200 )
#define HB_FILE_TYPE_MAX   128
#else

/* this has to be declared before hbapifs.h is included */
#define _HB_FILE_INTERNAL_
#endif
#include "hbapifs.h"
#include "inkey.ch"

#ifdef __XCC__
char                       *itoa( int __value, char *__string, int __radix );
#endif
#if defined( _MSC_VER ) && !defined( __POCC__ )
#define itoa( __value, __string, __radix )   _itoa( __value, __string, __radix )
#endif
#if defined( __XHARBOUR__ )
#define HB_LONGLONG  LONGLONG
extern HB_EXPORT void      hb_evalBlock0( PHB_ITEM pCodeBlock );
#endif
extern HB_EXPORT BOOL      Array2Rect( PHB_ITEM aRect, RECT *rc );
extern HB_EXPORT PHB_ITEM  Rect2Array( RECT *rc );
extern void                hmg_ErrorExit( LPCTSTR lpMessage, DWORD dwError, BOOL bExit );

typedef HMODULE ( __stdcall *SHGETFOLDERPATH ) ( HWND, int, HANDLE, DWORD, LPTSTR );

#ifdef UNICODE
LPWSTR   AnsiToWide( LPCSTR );
LPSTR    WideToAnsi( LPWSTR );
#endif
BOOL     SysRefresh( void );

// Minigui Resources control system
void     RegisterResource( HANDLE hResource, LPCSTR szType );

HB_PTRUINT wapi_GetProcAddress( HMODULE hModule, LPCSTR lpProcName )
{
   FARPROC pProc;

   pProc = GetProcAddress( hModule, lpProcName );
   return( HB_PTRUINT ) pProc;
}

/*
   WaitRun function for Minigui With Pipe redirection
   Author: Luiz Rafael Culik Guimaraes <culikr@uol.com.br>
   Parameters WaitRunPipe(cCommand,nShowWindow,cFile)
 */
HB_FUNC( WAITRUNPIPE )
{
   STARTUPINFO          StartupInfo;
   PROCESS_INFORMATION  ProcessInfo;
   HANDLE               ReadPipeHandle;
   HANDLE               WritePipeHandle;  // not used here
   char                 *Data;

#ifndef UNICODE
   LPSTR                lpCommandLine = ( char * ) hb_parc( 1 );
#else
   LPWSTR               lpCommandLine = AnsiToWide( ( char * ) hb_parc( 1 ) );
#endif
   const char           *szFile = ( const char * ) hb_parc( 3 );
   HB_FHANDLE           nHandle;
   SECURITY_ATTRIBUTES  sa;

   ZeroMemory( &sa, sizeof( SECURITY_ATTRIBUTES ) );
   sa.nLength = sizeof( SECURITY_ATTRIBUTES );
   sa.bInheritHandle = 1;
   sa.lpSecurityDescriptor = NULL;

   memset( &StartupInfo, 0, sizeof( StartupInfo ) );
   memset( &ProcessInfo, 0, sizeof( ProcessInfo ) );

   if( !hb_fsFile( szFile ) )
   {
      nHandle = hb_fsCreate( szFile, 0 );
   }
   else
   {
      nHandle = hb_fsOpen( szFile, 2 );
      hb_fsSeek( nHandle, 0, 2 );
   }

   if( !CreatePipe( &ReadPipeHandle, &WritePipeHandle, &sa, 0 ) )
   {
      hb_retni( -1 );
      return;
   }

   ProcessInfo.hProcess = INVALID_HANDLE_VALUE;
   ProcessInfo.hThread = INVALID_HANDLE_VALUE;
   StartupInfo.dwFlags = STARTF_USESHOWWINDOW | STARTF_USESTDHANDLES;
   StartupInfo.wShowWindow = hmg_par_WORD( 2 );
   StartupInfo.hStdOutput = WritePipeHandle;
   StartupInfo.hStdError = WritePipeHandle;

   if( !CreateProcess( NULL, lpCommandLine, 0, 0, FALSE, CREATE_NEW_CONSOLE | NORMAL_PRIORITY_CLASS, 0, 0, &StartupInfo, &ProcessInfo ) )
   {
      hb_retni( -1 );
      return;
   }
   else
   {
#ifdef UNICODE
      hb_xfree( ( TCHAR * ) lpCommandLine );
#endif
   }

   Data = ( char * ) hb_xgrab( 1024 );
   for( ;; )
   {
      DWORD BytesRead;
      DWORD TotalBytes;
      DWORD BytesLeft;

      // Check for the presence of data in the pipe
      if( !PeekNamedPipe( ReadPipeHandle, Data, sizeof( Data ), &BytesRead, &TotalBytes, &BytesLeft ) )
      {
         hb_retni( -1 );
         return;
      }

      // If there is bytes, read them
      if( BytesRead )
      {
         if( !ReadFile( ReadPipeHandle, Data, sizeof( Data ) -1, &BytesRead, NULL ) )
         {
            hb_retni( -1 );
            return;
         }

         Data[BytesRead] = TEXT( '\0' );
         hb_fsWriteLarge( nHandle, Data, BytesRead );
      }
      else
      {
         // Is the console app terminated?
         if( WaitForSingleObject( ProcessInfo.hProcess, 0 ) == WAIT_OBJECT_0 )
         {
            break;
         }
      }
   }

   CloseHandle( ProcessInfo.hThread );
   CloseHandle( ProcessInfo.hProcess );
   CloseHandle( ReadPipeHandle );
   CloseHandle( WritePipeHandle );
   hb_fsClose( nHandle );
   hb_xfree( Data );
}

HB_FUNC( COPYRTFTOCLIPBOARD ) // CopyRtfToClipboard(cRtfText) store cRTFText in Windows clipboard
{
   HGLOBAL     hglbCopy;
   char        *lptstrCopy;
   UINT        cf;
   const char  *cStr = HB_ISCHAR( 1 ) ? hb_parc( 1 ) : "";
   int         nLen = ( int ) strlen( cStr );

   if( ( nLen == 0 ) || !OpenClipboard( GetActiveWindow() ) )
   {
      return;
   }

   // Get Clipboard format id for RTF.
   cf = RegisterClipboardFormat( TEXT( "Rich Text Format" ) );

   EmptyClipboard();

   hglbCopy = GlobalAlloc( GMEM_MOVEABLE | GMEM_DDESHARE, ( nLen + 4 ) * sizeof( TCHAR ) );
   if( hglbCopy == NULL )
   {
      CloseClipboard();
      return;
   }

   lptstrCopy = ( char * ) GlobalLock( hglbCopy );
   memcpy( lptstrCopy, cStr, nLen * sizeof( TCHAR ) );
   lptstrCopy[nLen] = ( TCHAR ) 0;  // NULL character
   GlobalUnlock( hglbCopy );

   SetClipboardData( cf, hglbCopy );
   CloseClipboard();
}

HB_FUNC( COPYTOCLIPBOARD ) // CopyToClipboard(cText) store cText in Windows clipboard
{
   HGLOBAL     hglbCopy;
   char        *lptstrCopy;

   const char  *cStr = HB_ISCHAR( 1 ) ? hb_parc( 1 ) : "";
   int         nLen = ( int ) strlen( cStr );

   if( ( nLen == 0 ) || !OpenClipboard( GetActiveWindow() ) )
   {
      return;
   }

   EmptyClipboard();

   hglbCopy = GlobalAlloc( GMEM_DDESHARE, ( nLen + 1 ) * sizeof( TCHAR ) );
   if( hglbCopy == NULL )
   {
      CloseClipboard();
      return;
   }

   lptstrCopy = ( char * ) GlobalLock( hglbCopy );
   memcpy( lptstrCopy, cStr, nLen * sizeof( TCHAR ) );
   lptstrCopy[nLen] = ( TCHAR ) 0;  // null character
   GlobalUnlock( hglbCopy );

   SetClipboardData( HB_ISNUM( 2 ) ? hmg_par_UINT( 2 ) : CF_TEXT, hglbCopy );
   CloseClipboard();
}

HB_FUNC( RETRIEVETEXTFROMCLIPBOARD )
{
   HGLOBAL  hClipMem;
   LPSTR    lpClip;

   if( IsClipboardFormatAvailable( CF_TEXT ) && OpenClipboard( GetActiveWindow() ) )
   {
      hClipMem = GetClipboardData( CF_TEXT );
      if( hClipMem )
      {
         lpClip = ( LPSTR ) GlobalLock( hClipMem );
         if( lpClip )
         {
            hb_retc( lpClip );
            GlobalUnlock( hClipMem );
         }
         else
         {
            hb_retc( "" );
         }
      }
      else
      {
         hb_retc_null();
      }

      CloseClipboard();
   }
   else
   {
      hb_retc_null();
   }
}

HB_FUNC( CLEARCLIPBOARD )
{
   if( OpenClipboard( hmg_par_raw_HWND( 1 ) ) )
   {
      EmptyClipboard();
      CloseClipboard();
      hb_retl( TRUE );
   }
   else
   {
      hb_retl( FALSE );
   }
}

HB_FUNC( GETBLUE )
{
   hmg_ret_UINT( GetBValue( hmg_par_COLORREF( 1 ) ) );
}

HB_FUNC( GETRED )
{
   hmg_ret_UINT( GetRValue( hmg_par_COLORREF( 1 ) ) );
}

HB_FUNC( GETGREEN )
{
   hmg_ret_UINT( GetGValue( hmg_par_COLORREF( 1 ) ) );
}

HB_FUNC( GETKEYSTATE )
{
   hmg_ret_NI( GetKeyState( hb_parni( 1 ) ) );
}

HB_FUNC( GETASYNCKEYSTATE )
{
   hmg_ret_NI( GetAsyncKeyState( hb_parni( 1 ) ) );
}

HB_FUNC( HMG_KEYBOARDCLEARBUFFER )
{
   MSG   Msg;

   while( PeekMessage( &Msg, NULL, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE ) );
}

HB_FUNC( HMG_MOUSECLEARBUFFER )
{
   MSG   Msg;

   while( PeekMessage( &Msg, NULL, WM_MOUSEFIRST, WM_MOUSELAST, PM_REMOVE ) );
}

#ifndef USER_TIMER_MINIMUM
#define USER_TIMER_MINIMUM 0x0000000A
#endif
#ifndef USER_TIMER_MAXIMUM
#define USER_TIMER_MAXIMUM 0x7FFFFFFF
#endif
HB_FUNC( INKEYGUI )
{
   UINT     uElapse = hb_parnidef( 1, USER_TIMER_MINIMUM );
   UINT_PTR uTimer;
   MSG      Msg;
   BOOL     bRet, bBreak = FALSE;
   UINT     uRet = 0;

   if( uElapse == 0 )
   {
      uElapse = USER_TIMER_MAXIMUM;
   }

   uTimer = SetTimer( NULL, 0, uElapse, NULL );

   while( ( bRet = GetMessage( &Msg, NULL, 0, 0 ) ) != 0 )
   {
      if( bRet == -1 )
      {
         // handle the error and possibly exit
         hmg_ErrorExit( TEXT( "INKEYGUI" ), 0, TRUE );
      }
      else
      {
         switch( Msg.message )
         {
            case WM_KEYDOWN:
            case WM_SYSKEYDOWN:
               bBreak = TRUE;
               uRet = ( UINT ) Msg.wParam;
               break;

            case WM_TIMER:
               bBreak = ( Msg.wParam == uTimer );
               break;

            case WM_LBUTTONDOWN:
            case WM_RBUTTONDOWN:
               bBreak = TRUE;
               uRet = ( Msg.message == WM_LBUTTONDOWN ) ? K_LBUTTONDOWN : K_RBUTTONDOWN;
               PostMessage( Msg.hwnd, Msg.message, Msg.wParam, Msg.lParam );
               break;
         }
      }

      if( bBreak )
      {
         KillTimer( NULL, uTimer );
         break;
      }
      else
      {
         TranslateMessage( &Msg );  // Translates virtual key codes
         DispatchMessage( &Msg );   // Dispatches message to window
      }
   }

   hb_retns( uRet );
}

HB_FUNC( GETDC )
{
   hmg_ret_raw_HDC( GetDC( hmg_par_raw_HWND( 1 ) ) );
}

HB_FUNC( RELEASEDC )
{
   hb_retl( ReleaseDC( hmg_par_raw_HWND( 1 ), hmg_par_raw_HDC( 2 ) ) );
}

HB_FUNC( HIWORD )
{
   hmg_ret_WORD( HIWORD( hmg_par_DWORD( 1 ) ) );
}

HB_FUNC( LOWORD )
{
   hmg_ret_WORD( LOWORD( hmg_par_DWORD( 1 ) ) );
}

HB_FUNC( C_GETSPECIALFOLDER ) // Contributed By Ryszard Ry�ko
{
#ifdef UNICODE
   LPSTR          pStr;
#endif
   TCHAR          *lpBuffer = ( TCHAR * ) hb_xgrab( ( MAX_PATH + 1 ) * sizeof( TCHAR ) );
   LPITEMIDLIST   pidlBrowse; // PIDL selected by user
   SHGetSpecialFolderLocation( GetActiveWindow(), hb_parni( 1 ), &pidlBrowse );
   SHGetPathFromIDList( pidlBrowse, lpBuffer );

#ifndef UNICODE
   hb_retc( lpBuffer );
#else
   pStr = hb_osStrU16Decode( lpBuffer );
   hb_retc( pStr );
   hb_xfree( pStr );
#endif
   hb_xfree( lpBuffer );
}

//#define __WIN98__
#ifdef __WIN98__

/*
   Based Upon Code Contributed By Jacek Kubica <kubica@wssl.wroc.pl>
   Updated by Vailton Renato <vailtom@gmail.com>
 */
HB_FUNC( C_GETDLLSPECIALFOLDER )
{
   TCHAR    szPath[MAX_PATH];
   HMODULE  hModule = LoadLibrary( TEXT( "SHFolder.dll" ) );

   if( hModule )
   {
      SHGETFOLDERPATH   fnShGetFolderPath = ( SHGETFOLDERPATH ) wapi_GetProcAddress( hModule, "SHGetFolderPathA" );

      if( fnShGetFolderPath )
      {
         if( fnShGetFolderPath( NULL, hb_parni( 1 ), NULL, 0, szPath ) == S_OK )
         {
            hb_retc( szPath );
         }
         else
         {
            hb_retc( "" );
         }
      }

      FreeLibrary( hModule );
   }
}
#endif /* __WIN98__ */

// Memory Management Functions
typedef BOOL ( WINAPI *GetPhysicallyInstalledSystemMemory_ptr ) ( ULONGLONG * );

HB_FUNC( GETPHYSICALLYINSTALLEDSYSTEMMEMORY )
{
   HMODULE  hDll = GetModuleHandle( TEXT( "kernel32.dll" ) );

   hb_retnll( 0 );

   if( NULL != hDll )
   {
      GetPhysicallyInstalledSystemMemory_ptr fn_GetPhysicallyInstalledSystemMemory = ( GetPhysicallyInstalledSystemMemory_ptr ) wapi_GetProcAddress
         (
            hDll,
            "GetPhysicallyInstalledSystemMemory"
         );

      if( NULL != fn_GetPhysicallyInstalledSystemMemory )
      {
         ULONGLONG   ullTotalMemoryInKilobytes;

         if( fn_GetPhysicallyInstalledSystemMemory( &ullTotalMemoryInKilobytes ) )
         {
            hb_retnll( ( HB_LONGLONG ) ullTotalMemoryInKilobytes );
         }
      }
   }
}

typedef BOOL ( WINAPI *GlobalMemoryStatusEx_ptr ) ( MEMORYSTATUSEX * );
#define DIV ( 1024 * 1024 )

HB_FUNC( MEMORYSTATUS )
{
   HMODULE  hDll = GetModuleHandle( TEXT( "kernel32.dll" ) );

   HB_RETNL( 0 );

   if( NULL != hDll )
   {
      GlobalMemoryStatusEx_ptr   fn_GlobalMemoryStatusEx = ( GlobalMemoryStatusEx_ptr ) wapi_GetProcAddress( hDll, "GlobalMemoryStatusEx" );

      if( NULL != fn_GlobalMemoryStatusEx )
      {
         MEMORYSTATUSEX mstex;

         mstex.dwLength = sizeof( mstex );

         if( fn_GlobalMemoryStatusEx( &mstex ) )
         {
            switch( hb_parni( 1 ) )
            {
               case 1:
                  hb_retnll( mstex.ullTotalPhys / DIV );
                  break;

               case 2:
                  hb_retnll( mstex.ullAvailPhys / DIV );
                  break;

               case 3:
                  hb_retnll( mstex.ullTotalPageFile / DIV );
                  break;

               case 4:
                  hb_retnll( mstex.ullAvailPageFile / DIV );
                  break;

               case 5:
                  hb_retnll( mstex.ullTotalVirtual / DIV );
                  break;

               case 6:
                  hb_retnll( mstex.ullAvailVirtual / DIV );
                  break;
            }
         }
      }
      else
      {
         MEMORYSTATUS   mst;

         mst.dwLength = sizeof( MEMORYSTATUS );
         GlobalMemoryStatus( &mst );

         switch( hb_parni( 1 ) )
         {
            case 1:
               HB_RETNL( mst.dwTotalPhys / DIV );
               break;

            case 2:
               HB_RETNL( mst.dwAvailPhys / DIV );
               break;

            case 3:
               HB_RETNL( mst.dwTotalPageFile / DIV );
               break;

            case 4:
               HB_RETNL( mst.dwAvailPageFile / DIV );
               break;

            case 5:
               HB_RETNL( mst.dwTotalVirtual / DIV );
               break;

            case 6:
               HB_RETNL( mst.dwAvailVirtual / DIV );
               break;
         }
      }
   }
}

HB_FUNC( C_SHELLABOUT )
{
#ifndef UNICODE
   LPCSTR   szApp = hb_parc( 2 );
   LPCSTR   szOtherStuff = hb_parc( 3 );
#else
   LPCWSTR  szApp = AnsiToWide( ( char * ) hb_parc( 2 ) );
   LPCWSTR  szOtherStuff = AnsiToWide( ( char * ) hb_parc( 3 ) );
#endif
   hb_retl( ShellAbout( hmg_par_raw_HWND( 1 ), szApp, szOtherStuff, hmg_par_raw_HICON( 4 ) ) );
#ifdef UNICODE
   hb_xfree( ( TCHAR * ) szApp );
   hb_xfree( ( TCHAR * ) szOtherStuff );
#endif
}

HB_FUNC( PAINTBKGND )
{
   HWND     hwnd;
   HBRUSH   hBrush;
   RECT     recClie;
   HDC      hdc;

   hwnd = hmg_par_raw_HWND( 1 );
   hdc = GetDC( hwnd );

   GetClientRect( hwnd, &recClie );

   if( hb_pcount() > 1 && !HB_ISNIL( 2 ) )
   {
      hBrush = CreateSolidBrush( RGB( HB_PARNI( 2, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 3 ) ) );
      FillRect( hdc, &recClie, hBrush );
   }
   else
   {
      hBrush = ( HBRUSH ) ( COLOR_BTNFACE + 1 );
      FillRect( hdc, &recClie, hBrush );
   }

   ReleaseDC( hwnd, hdc );

   RegisterResource( hBrush, "BRUSH" );
   hmg_ret_raw_HBRUSH( hBrush );
}

/* Functions Contributed  By Luiz Rafael Culik Guimaraes( culikr@uol.com.br) */
HB_FUNC( GETWINDOWSDIR )
{
   TCHAR szBuffer[MAX_PATH + 1] = { 0 };

#ifdef UNICODE
   LPSTR pStr;
#endif
   GetWindowsDirectory( szBuffer, MAX_PATH );

#ifndef UNICODE
   hb_retc( szBuffer );
#else
   pStr = WideToAnsi( szBuffer );
   hb_retc( pStr );
   hb_xfree( pStr );
#endif
}

HB_FUNC( GETSYSTEMDIR )
{
   TCHAR szBuffer[MAX_PATH + 1] = { 0 };

#ifdef UNICODE
   LPSTR pStr;
#endif
   GetSystemDirectory( szBuffer, MAX_PATH );

#ifndef UNICODE
   hb_retc( szBuffer );
#else
   pStr = WideToAnsi( szBuffer );
   hb_retc( pStr );
   hb_xfree( pStr );
#endif
}

HB_FUNC( GETTEMPDIR )
{
   TCHAR szBuffer[MAX_PATH + 1] = { 0 };

#ifdef UNICODE
   LPSTR pStr;
#endif
   GetTempPath( MAX_PATH, szBuffer );

#ifndef UNICODE
   hb_retc( szBuffer );
#else
   pStr = WideToAnsi( szBuffer );
   hb_retc( pStr );
   hb_xfree( pStr );
#endif
}

HB_FUNC( POSTMESSAGE )
{
   hmg_ret_LONG( PostMessage( hmg_par_raw_HWND( 1 ), hmg_par_UINT( 2 ), hmg_par_WPARAM( 3 ), hmg_par_LPARAM( 4 ) ) );
}

HB_FUNC( DEFWINDOWPROC )
{
   hmg_ret_LRESULT( DefWindowProc( hmg_par_raw_HWND( 1 ), hmg_par_UINT( 2 ), hmg_par_WPARAM( 3 ), hmg_par_LPARAM( 4 ) ) );
}

HB_FUNC( GETSTOCKOBJECT )
{
   hmg_ret_raw_HGDIOBJ( GetStockObject( hb_parni( 1 ) ) );
}

HB_FUNC( GETNEXTDLGTABITEM )
{
   hmg_ret_raw_HWND( GetNextDlgTabItem( hmg_par_raw_HWND( 1 ), hmg_par_raw_HWND( 2 ), hb_parl( 3 ) ) );
}

typedef BOOL ( WINAPI *LPFN_ISWOW64PROCESS ) ( HANDLE, PBOOL );
typedef BOOL ( WINAPI *LPFN_WOW64DISABLEWOW64FSREDIRECTION ) ( PVOID * );
typedef BOOL ( WINAPI *LPFN_WOW64REVERTWOW64FSREDIRECTION ) ( PVOID );

HB_FUNC( SHELLEXECUTE )
{
#ifndef UNICODE
   LPCSTR                              lpOperation = hb_parc( 2 );
   LPCSTR                              lpFile = hb_parc( 3 );
   LPCSTR                              lpParameters = hb_parc( 4 );
   LPCSTR                              lpDirectory = hb_parc( 5 );
#else
   LPCWSTR                             lpOperation = AnsiToWide( ( char * ) hb_parc( 2 ) );
   LPCWSTR                             lpFile = AnsiToWide( ( char * ) hb_parc( 3 ) );
   LPCWSTR                             lpParameters = AnsiToWide( ( char * ) hb_parc( 4 ) );
   LPCWSTR                             lpDirectory = AnsiToWide( ( char * ) hb_parc( 5 ) );
#endif
   LPFN_ISWOW64PROCESS                 fnIsWow64Process;
   BOOL                                bIsWow64 = FALSE;
   LPFN_WOW64DISABLEWOW64FSREDIRECTION fnDisable;
   PVOID                               OldValue = NULL;
   BOOL                                bRestore = FALSE;
   LPFN_WOW64REVERTWOW64FSREDIRECTION  fnRevert;
   HMODULE                             hDll = GetModuleHandle( TEXT( "kernel32.dll" ) );

   fnIsWow64Process = ( LPFN_ISWOW64PROCESS ) wapi_GetProcAddress( hDll, "IsWow64Process" );
   if( NULL != fnIsWow64Process )
   {
      fnIsWow64Process( GetCurrentProcess(), &bIsWow64 );
   }

   if( bIsWow64 )
   {
      fnDisable = ( LPFN_WOW64DISABLEWOW64FSREDIRECTION ) wapi_GetProcAddress( hDll, "Wow64DisableWow64FsRedirection" );
      if( NULL != fnDisable )
      {
         if( fnDisable( &OldValue ) )
         {
            bRestore = TRUE;
         }
      }
   }

   CoInitialize( NULL );

   hmg_ret_raw_HANDLE
   (
      ShellExecute
         (
            hmg_par_raw_HWND( 1 ),
            HB_ISNIL( 2 ) ? NULL : lpOperation,
            lpFile,
            HB_ISNIL( 4 ) ? NULL : lpParameters,
            HB_ISNIL( 5 ) ? NULL : lpDirectory,
            hb_parni( 6 )
         )
   );

   hb_idleSleep( 1.0 );

   if( bRestore )
   {
      fnRevert = ( LPFN_WOW64REVERTWOW64FSREDIRECTION ) wapi_GetProcAddress( hDll, "Wow64RevertWow64FsRedirection" );
      if( NULL != fnRevert )
      {
         fnRevert( OldValue );
      }
   }

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpOperation );
   hb_xfree( ( TCHAR * ) lpFile );
   hb_xfree( ( TCHAR * ) lpParameters );
   hb_xfree( ( TCHAR * ) lpDirectory );
#endif
}

HB_FUNC( SHELLEXECUTEEX )
{
#ifndef UNICODE
   LPCSTR            lpOperation = hb_parc( 2 );
   LPCSTR            lpFile = hb_parc( 3 );
   LPCSTR            lpParameters = hb_parc( 4 );
   LPCSTR            lpDirectory = hb_parc( 5 );
#else
   LPCWSTR           lpOperation = AnsiToWide( ( char * ) hb_parc( 2 ) );
   LPCWSTR           lpFile = AnsiToWide( ( char * ) hb_parc( 3 ) );
   LPCWSTR           lpParameters = AnsiToWide( ( char * ) hb_parc( 4 ) );
   LPCWSTR           lpDirectory = AnsiToWide( ( char * ) hb_parc( 5 ) );
#endif
   SHELLEXECUTEINFO  SHExecInfo;
   ZeroMemory( &SHExecInfo, sizeof( SHExecInfo ) );

   SHExecInfo.cbSize = sizeof( SHExecInfo );
   SHExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
   SHExecInfo.hwnd = HB_ISNIL( 1 ) ? GetActiveWindow() : hmg_par_raw_HWND( 1 );
   SHExecInfo.lpVerb = HB_ISNIL( 2 ) ? NULL : lpOperation;
   SHExecInfo.lpFile = lpFile;
   SHExecInfo.lpParameters = HB_ISNIL( 4 ) ? NULL : lpParameters;
   SHExecInfo.lpDirectory = HB_ISNIL( 5 ) ? NULL : lpDirectory;
   SHExecInfo.nShow = hb_parni( 6 );

   if( ShellExecuteEx( &SHExecInfo ) )
   {
      hmg_ret_raw_HWND( SHExecInfo.hProcess );
   }
   else
   {
      hmg_ret_raw_HWND( NULL );
   }

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpOperation );
   hb_xfree( ( TCHAR * ) lpFile );
   hb_xfree( ( TCHAR * ) lpParameters );
   hb_xfree( ( TCHAR * ) lpDirectory );
#endif
}

HB_FUNC( WAITRUN )
{
   DWORD                dwExitCode;

#ifndef UNICODE
   LPSTR                lpCommandLine = ( char * ) hb_parc( 1 );
#else
   LPWSTR               lpCommandLine = AnsiToWide( ( char * ) hb_parc( 1 ) );
#endif
   STARTUPINFO          stInfo;
   PROCESS_INFORMATION  prInfo;
   BOOL                 bResult;

   ZeroMemory( &stInfo, sizeof( stInfo ) );

   stInfo.cb = sizeof( stInfo );

   stInfo.dwFlags = STARTF_USESHOWWINDOW;

   stInfo.wShowWindow = hmg_par_WORD( 2 );

   bResult = CreateProcess( NULL, lpCommandLine, NULL, NULL, TRUE, CREATE_NEW_CONSOLE | NORMAL_PRIORITY_CLASS, NULL, NULL, &stInfo, &prInfo );

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpCommandLine );
#endif
   if( !bResult )
   {
      hb_retni( -1 );
      return;
   }

   WaitForSingleObject( prInfo.hProcess, INFINITE );

   GetExitCodeProcess( prInfo.hProcess, &dwExitCode );

   CloseHandle( prInfo.hThread );
   CloseHandle( prInfo.hProcess );

   hmg_ret_DWORD( dwExitCode );
}

/* WaitRunTerm contributed by Kevin Carmody (i@kevincarmody.com) 2007.11.16 */
HB_FUNC( WAITRUNTERM )
{
#ifndef UNICODE
   LPSTR                lpCommandLine = ( char * ) hb_parc( 1 );
   LPCSTR               lpCurrentDirectory = hb_parc( 2 );
#else
   LPWSTR               lpCommandLine = AnsiToWide( ( char * ) hb_parc( 1 ) );
   LPCWSTR              lpCurrentDirectory = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   PHB_ITEM             pWaitProc = hb_param( 4, HB_IT_BLOCK );
   ULONG                ulWaitMsec = ( HB_ISNIL( 5 ) ? 2000 : hb_parnl( 5 ) );
   BOOL                 bTerm = FALSE;
   BOOL                 bWait;
   ULONG                ulNoSignal;
   DWORD                dwExitCode;
   STARTUPINFO          stInfo;
   PROCESS_INFORMATION  prInfo;
   BOOL                 bResult;

   ZeroMemory( &stInfo, sizeof( stInfo ) );
   stInfo.cb = sizeof( stInfo );
   stInfo.dwFlags = STARTF_USESHOWWINDOW;
   stInfo.wShowWindow = HB_ISNIL( 3 ) ? ( WORD ) 5 : hmg_par_WORD( 3 );

   bResult = CreateProcess
      (
         NULL,
         lpCommandLine,
         NULL,
         NULL,
         TRUE,
         CREATE_NEW_CONSOLE | NORMAL_PRIORITY_CLASS,
         NULL,
         HB_ISNIL( 2 ) ? NULL : lpCurrentDirectory,
         &stInfo,
         &prInfo
      );

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpCommandLine );
   hb_xfree( ( TCHAR * ) lpCurrentDirectory );
#endif
   if( !bResult )
   {
      hb_retni( -2 );
      return;
   }

   if( pWaitProc )
   {
      do
      {
         ulNoSignal = WaitForSingleObject( prInfo.hProcess, ulWaitMsec );
         if( ulNoSignal )
         {
            hb_evalBlock0( pWaitProc );
            bWait = hb_parl( -1 );
            if( !bWait )
            {
               if( TerminateProcess( prInfo.hProcess, 0 ) != 0 )
               {
                  bTerm = TRUE;
               }
               else
               {
                  bWait = TRUE;
               }
            }
         }
         else
         {
            bWait = FALSE;
         }
      }
      while( bWait );
   }
   else
   {
      WaitForSingleObject( prInfo.hProcess, INFINITE );
   }

   if( bTerm )
   {
      dwExitCode = ( DWORD ) -1;
   }
   else
   {
      GetExitCodeProcess( prInfo.hProcess, &dwExitCode );
   }

   CloseHandle( prInfo.hThread );
   CloseHandle( prInfo.hProcess );
   hmg_ret_DWORD( dwExitCode );
}

HB_FUNC( ISEXERUNNING ) // ( cExeNameCaseSensitive ) --> lResult
{
   HANDLE   hMutex = CreateMutex( NULL, FALSE, ( LPTSTR ) hb_parc( 1 ) );

   hb_retl( GetLastError() == ERROR_ALREADY_EXISTS );

   if( hMutex != NULL )
   {
      ReleaseMutex( hMutex );
   }
}

HB_FUNC( SETSCROLLPOS )
{
   hmg_ret_NINT( SetScrollPos( hmg_par_raw_HWND( 1 ), hb_parni( 2 ), hb_parni( 3 ), hb_parl( 4 ) ) );
}

HB_FUNC( GETLASTERROR )
{
   hmg_ret_DWORD( GetLastError() );
}

HB_FUNC( CREATEFOLDER )
{
#ifndef UNICODE
   LPCSTR   lpPathName = hb_parc( 1 );
#else
   LPCWSTR  lpPathName = AnsiToWide( hb_parc( 1 ) );
#endif
   hb_retl( CreateDirectory( lpPathName, NULL ) );
#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpPathName );
#endif
}

HB_FUNC( SETCURRENTFOLDER )
{
#ifndef UNICODE
   LPCSTR   lpPathName = hb_parc( 1 );
#else
   LPCWSTR  lpPathName = AnsiToWide( hb_parc( 1 ) );
#endif
   hb_retl( SetCurrentDirectory( lpPathName ) );
#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpPathName );
#endif
}

HB_FUNC( REMOVEFOLDER )
{
#ifndef UNICODE
   LPCSTR   lpPathName = hb_parc( 1 );
#else
   LPCWSTR  lpPathName = AnsiToWide( hb_parc( 1 ) );
#endif
   hb_retl( RemoveDirectory( lpPathName ) );
#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpPathName );
#endif
}

HB_FUNC( GETCURRENTFOLDER )
{
   TCHAR Path[MAX_PATH + 1] = { 0 };

#ifdef UNICODE
   LPSTR pStr;
#endif
   GetCurrentDirectory( MAX_PATH, Path );
#ifndef UNICODE
   hb_retc( Path );
#else
   pStr = WideToAnsi( Path );
   hb_retc( pStr );
   hb_xfree( pStr );
#endif
}

HB_FUNC( CREATESOLIDBRUSH )
{
   HBRUSH   hBrush = CreateSolidBrush( RGB( hb_parni( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) );

   RegisterResource( hBrush, "BRUSH" );
   hmg_ret_raw_HBRUSH( hBrush );
}

HB_FUNC( SETTEXTCOLOR )
{
   hmg_ret_COLORREF( SetTextColor( hmg_par_raw_HDC( 1 ), RGB( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) ) );
}

HB_FUNC( SETBKCOLOR )
{
   hmg_ret_COLORREF( SetBkColor( hmg_par_raw_HDC( 1 ), RGB( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) ) );
}

HB_FUNC( GETSYSCOLOR )
{
   hmg_ret_DWORD( GetSysColor( hb_parni( 1 ) ) );
}

/**************************************************************************************/
/*                                                                                    */
/*  This function returns the Windows Version on which the app calling the function   */
/*  is running.                                                                       */
/*                                                                                    */
/*  The return value is an 4-th dimensinal array containing the OS in the first,      */
/*  the servicepack or the system release number in the second, the build number      */
/*  in the third and extended OS information in the fourth array element.             */
/*                                                                                    */
/**************************************************************************************/
HB_FUNC( WINVERSION )
{
#if defined( __BORLANDC__ )
#define VER_SUITE_PERSONAL 0x00000200
#define VER_SUITE_BLADE    0x00000400
#endif

   // Struct for OS version information and extended OS information
   OSVERSIONINFOEX   osvi;
   BOOL              bOsVersionInfoEx;

   // Pointers to hold OS version, Service Pack, build number, and additional version info
   TCHAR             *szVersion = NULL;
   TCHAR             *szServicePack = NULL;
   TCHAR             *szBuild = NULL;
   TCHAR             buffer[5]; // For numeric conversions

   TCHAR             *szVersionEx = NULL;
#ifdef UNICODE
   LPSTR             pStr; // Pointer for ANSI conversion in Unicode build
#endif

   ZeroMemory( &osvi, sizeof( OSVERSIONINFOEX ) );
   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFOEX );

   // Attempt to get extended version information (OSVERSIONINFOEX)
   bOsVersionInfoEx = GetVersionEx( ( OSVERSIONINFO * ) &osvi );
   if( !bOsVersionInfoEx )
   {
      osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );

      // If extended info retrieval fails, try basic version info
      if( !GetVersionEx( ( OSVERSIONINFO * ) &osvi ) )
      {
         szVersion = TEXT( "Unknown Operating System" );
      }
   }

   // Identify OS version and service pack based on version number and platform
   if( szVersion == NULL )
   {
      switch( osvi.dwPlatformId )
      {
         case VER_PLATFORM_WIN32_NT:
            // Windows NT-based systems
            if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 2 )
            {
               szVersion = TEXT( "Windows Server 2003 family " );
            }

            if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 1 )
            {
               szVersion = TEXT( "Windows XP " );
            }

            if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 0 )
            {
               szVersion = TEXT( "Windows 2000 " );
            }

            if( osvi.dwMajorVersion <= 4 )
            {
               szVersion = TEXT( "Windows NT " );
            }

            // Additional OS version info if OSVERSIONINFOEX is supported
            if( bOsVersionInfoEx )
            {
               if( osvi.wProductType == VER_NT_WORKSTATION )
               {
                  // Workstation versions
                  if( osvi.dwMajorVersion == 10 && osvi.dwBuildNumber >= 22000 )
                  {
                     szVersion = TEXT( "Windows 11 " );
                  }
                  else if( osvi.dwMajorVersion == 10 && osvi.dwMinorVersion == 0 )
                  {
                     szVersion = TEXT( "Windows 10 " );
                  }
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 3 )
                  {
                     szVersion = TEXT( "Windows 8.1 " );
                  }
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 2 )
                  {
                     szVersion = TEXT( "Windows 8 " );
                  }
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 1 )
                  {
                     szVersion = TEXT( "Windows 7 " );
                  }
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 0 )
                  {
                     szVersion = TEXT( "Windows Vista " );
                  }

                  if( osvi.dwMajorVersion == 4 )
                  {
                     szVersionEx = TEXT( "Workstation 4.0 " );
                  }
                  else if( osvi.wSuiteMask & VER_SUITE_PERSONAL )
                  {
                     szVersionEx = TEXT( "Home Edition " );
                  }
                  else
                  {
                     szVersionEx = TEXT( "Professional " );
                  }
               }
               else if( osvi.wProductType == VER_NT_SERVER )
               {
                  // Server versions
                  if( osvi.dwMajorVersion == 10 && osvi.dwMinorVersion == 0 )
                  {
                     if (osvi.dwBuildNumber >= 20348)
                        szVersion = TEXT("Windows Server 2022");
                     else if (osvi.dwBuildNumber >= 17763)
                        szVersion = TEXT("Windows Server 2019");
                     else
                        szVersion = TEXT("Windows Server 2016");
                  }
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 3 )
                  {
                     szVersion = TEXT( "Windows Server 2012 R2 " );
                  }
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 2 )
                  {
                     szVersion = TEXT( "Windows Server 2012 " );
                  }
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 1 )
                  {
                     szVersion = TEXT( "Windows Server 2008 R2 " );
                  }
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 0 )
                  {
                     szVersion = TEXT( "Windows Server 2008 " );
                  }
                  else if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 2 )
                  {
                     if( osvi.wSuiteMask & VER_SUITE_DATACENTER )
                     {
                        szVersionEx = TEXT( "Datacenter Edition " );
                     }
                     else if( osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
                     {
                        szVersionEx = TEXT( "Enterprise Edition " );
                     }
                     else if( osvi.wSuiteMask & VER_SUITE_BLADE )
                     {
                        szVersionEx = TEXT( "Web Edition " );
                     }
                     else
                     {
                        szVersionEx = TEXT( "Standard Edition " );
                     }
                  }
                  else if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 0 )
                  {
                     if( osvi.wSuiteMask & VER_SUITE_DATACENTER )
                     {
                        szVersionEx = TEXT( "Datacenter Server " );
                     }
                     else if( osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
                     {
                        szVersionEx = TEXT( "Advanced Server " );
                     }
                     else
                     {
                        szVersionEx = TEXT( "Server " );
                     }
                  }
                  else
                  {
                     if( osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
                     {
                        szVersionEx = TEXT( "Server 4.0, Enterprise Edition " );
                     }
                     else
                     {
                        szVersionEx = TEXT( "Server 4.0 " );
                     }
                  }
               }
            }
            // Fallback registry-based check for pre-Windows 2000
            else
            {
               // Open registry to identify server or workstation version
               HKEY  hKey;
               TCHAR szProductType[80];
               DWORD dwBufLen = 80;
               LONG  lRetVal;

               lRetVal = RegOpenKeyEx( HKEY_LOCAL_MACHINE, TEXT( "SYSTEM\\CurrentControlSet\\Control\\ProductOptions" ), 0, KEY_QUERY_VALUE, &hKey );

               if( lRetVal != ERROR_SUCCESS )
               {
                  szVersion = TEXT( "Unknown Operating System" );
               }
               else
               {
                  lRetVal = RegQueryValueEx( hKey, TEXT( "ProductType" ), NULL, NULL, ( LPBYTE ) szProductType, &dwBufLen );
                  if( ( lRetVal != ERROR_SUCCESS ) || ( dwBufLen > 80 ) )
                  {
                     szVersion = TEXT( "Unknown Operating System" );
                  }
               }

               RegCloseKey( hKey );

               // Determine server/workstation from registry value
               if( lstrcmpi( TEXT( "Unknown Operating System" ), szVersion ) != 0 )
               {
                  if( lstrcmpi( TEXT( "WINNT" ), szProductType ) == 0 )
                  {
                     szVersionEx = TEXT( "Workstation " );
                  }

                  if( lstrcmpi( TEXT( "LANMANNT" ), szProductType ) == 0 )
                  {
                     szVersionEx = TEXT( "Server " );
                  }

                  if( lstrcmpi( TEXT( "SERVERNT" ), szProductType ) == 0 )
                  {
                     szVersionEx = TEXT( "Advanced Server " );
                  }

                  szVersion = lstrcat( szVersion, _itot( osvi.dwMajorVersion, buffer, 10 ) );
                  szVersion = lstrcat( szVersion, TEXT( "." ) );
                  szVersion = lstrcat( szVersion, _itot( osvi.dwMinorVersion, buffer, 10 ) );
               }
            }

            if( osvi.dwMajorVersion == 4 && lstrcmpi( osvi.szCSDVersion, TEXT( "Service Pack 6" ) ) == 0 )
            {
               HKEY  hKey;
               LONG  lRetVal;

               lRetVal = RegOpenKeyEx( HKEY_LOCAL_MACHINE, TEXT( "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Hotfix\\Q246009" ), 0, KEY_QUERY_VALUE, &hKey );
               if( lRetVal == ERROR_SUCCESS )
               {
                  szServicePack = TEXT( "Service Pack 6a" );
                  szBuild = _itot( osvi.dwBuildNumber & 0xFFFF, buffer, 10 );
               }
               else
               {
                  szServicePack = osvi.szCSDVersion;
                  szBuild = _itot( osvi.dwBuildNumber & 0xFFFF, buffer, 10 );
               }

               RegCloseKey( hKey );
            }
            else
            {
               szServicePack = osvi.szCSDVersion;
               szBuild = _itot( osvi.dwBuildNumber & 0xFFFF, buffer, 10 );
            }
            break;

         case VER_PLATFORM_WIN32_WINDOWS:
            // Windows 9x-based systems
            if( ( osvi.dwMajorVersion == 4 ) && ( osvi.dwMinorVersion == 0 ) )
            {
               if( osvi.szCSDVersion[1] == TEXT( 'B' ) )
               {
                  szVersion = TEXT( "Windows 95 B" );
                  szServicePack = TEXT( "OSR2" );
               }
               else
               {
                  if( osvi.szCSDVersion[1] == TEXT( 'C' ) )
                  {
                     szVersion = TEXT( "Windows 95 C" );
                     szServicePack = TEXT( "OSR2" );
                  }
                  else
                  {
                     szVersion = TEXT( "Windows 95" );
                     szServicePack = TEXT( "OSR1" );
                  }
               }

               szBuild = _itot( osvi.dwBuildNumber & 0x0000FFFF, buffer, 10 );
            }

            if( ( osvi.dwMajorVersion == 4 ) && ( osvi.dwMinorVersion == 10 ) )
            {
               if( osvi.szCSDVersion[1] == 'A' )
               {
                  szVersion = TEXT( "Windows 98 A" );
                  szServicePack = TEXT( "Second Edition" );
               }
               else
               {
                  szVersion = TEXT( "Windows 98" );
                  szServicePack = TEXT( "First Edition" );
               }

               szBuild = _itot( osvi.dwBuildNumber & 0x0000FFFF, buffer, 10 );
            }

            if( ( osvi.dwMajorVersion == 4 ) && ( osvi.dwMinorVersion == 90 ) )
            {
               szVersion = TEXT( "Windows ME" );
               szBuild = _itot( osvi.dwBuildNumber & 0x0000FFFF, buffer, 10 );
            }
            break;
      }
   }

   // Final storage and return of collected OS version details
   hb_reta( 4 );
#ifndef UNICODE
   HB_STORC( szVersion, -1, 1 );
   HB_STORC( szServicePack, -1, 2 );
   HB_STORC( szBuild, -1, 3 );
   HB_STORC( szVersionEx, -1, 4 );
#else
   pStr = WideToAnsi( szVersion );
   HB_STORC( pStr, -1, 1 );
   hb_xfree( pStr );
   pStr = WideToAnsi( szServicePack );
   HB_STORC( pStr, -1, 2 );
   hb_xfree( pStr );
   pStr = WideToAnsi( szBuild );
   HB_STORC( pStr, -1, 3 );
   hb_xfree( pStr );
   pStr = WideToAnsi( szVersionEx );
   HB_STORC( pStr, -1, 4 );
   hb_xfree( pStr );
#endif
}

#if defined( __XHARBOUR__ )
HB_FUNC( ISEXE64 )      // Check if our app is 64 bits
{
   hb_retl( ( sizeof( void * ) == 8 ) );
}
#endif
HB_FUNC( GETDLLVERSION )
{
   HMODULE  hModule;
   DWORD    dwMajorVersion = 0;
   DWORD    dwMinorVersion = 0;
   DWORD    dwBuildNumber = 0;

#ifndef UNICODE
   LPCSTR   lpLibFileName = hb_parc( 1 );
#else
   LPCWSTR  lpLibFileName = AnsiToWide( hb_parc( 1 ) );
#endif
   hModule = LoadLibrary( lpLibFileName );
   if( hModule )
   {
      DLLGETVERSIONPROC fnDllGetVersion;

      fnDllGetVersion = ( DLLGETVERSIONPROC ) wapi_GetProcAddress( hModule, "DllGetVersion" );

      if( fnDllGetVersion )
      {
         DLLVERSIONINFO dvi = { 0 };

         dvi.cbSize = sizeof( dvi );

         if( fnDllGetVersion( &dvi ) == S_OK )
         {
            dwMajorVersion = dvi.dwMajorVersion;
            dwMinorVersion = dvi.dwMinorVersion;
            dwBuildNumber = dvi.dwBuildNumber;
         }
      }
      else
      {
         MessageBox( NULL, TEXT( "Cannot get DllGetVersion function." ), TEXT( "DllGetVersion" ), MB_OK | MB_ICONERROR );
      }

      FreeLibrary( hModule );
   }

   hb_reta( 3 );
   HB_STORVNL( dwMajorVersion, -1, 1 );
   HB_STORVNL( dwMinorVersion, -1, 2 );
   HB_STORVNL( dwBuildNumber, -1, 3 );

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpLibFileName );
#endif
}

// Jacek Kubica <kubica@wssk.wroc.pl> HMG 1.0 Experimental Build 9a
HB_FUNC( SELECTOBJECT )
{
   hmg_ret_raw_HGDIOBJ( SelectObject( hmg_par_raw_HDC( 1 ), // handle of device context
   hmg_par_raw_HGDIOBJ( 2 ) // handle of object
   ) );
}

HB_FUNC( FILLRECT )
{
   HWND  hWnd = hmg_par_raw_HWND( 1 );
   HDC   hDC;
   BOOL  bDC = FALSE;

   if( IsWindow( hWnd ) )
   {
      hDC = GetDC( hWnd );
      bDC = TRUE;
   }
   else
   {
      hDC = hmg_par_raw_HDC( 1 );
   }

   if( GetObjectType( ( HGDIOBJ ) hDC ) == OBJ_DC )
   {
      RECT  rc;
      int   iParam = 6;

      if( Array2Rect( hb_param( 2, HB_IT_ANY ), &rc ) )
      {
         iParam = 3;
      }
      else
      {
         rc.left = hb_parni( 2 );
         rc.top = hb_parni( 3 );
         rc.right = hb_parni( 4 );
         rc.bottom = hb_parni( 5 );
      }

      hmg_ret_NINT( FillRect( hDC, &rc, hmg_par_raw_HBRUSH( iParam ) ) );

      if( bDC )
      {
         ReleaseDC( hWnd, hDC );
      }
   }
   else
   {
      hb_retni( 0 );
   }
}

#if defined( __MINGW32__ )
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wstrict-aliasing"
#endif /* __MINGW32__ */

#if ( defined( __POCC__ ) && __POCC__ >= 900 )
#ifndef _NO_W32_PSEUDO_MODIFIERS
#define IN
#define OUT
#endif
#endif
BOOL IsAppHung( IN HWND hWnd, OUT PBOOL pbHung )
{
   OSVERSIONINFO  osvi;
   HINSTANCE      hUser;

   if( !IsWindow( hWnd ) )
   {
      return SetLastError( ERROR_INVALID_PARAMETER ), FALSE;
   }

   osvi.dwOSVersionInfoSize = sizeof( osvi );

   // detect OS version
   GetVersionEx( &osvi );

   // get handle of USER32.DLL
   hUser = GetModuleHandle( TEXT( "user32.dll" ) );

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
   {
      BOOL ( WINAPI *_IsHungAppWindow ) ( HWND );

      // found the function IsHungAppWindow
      *( FARPROC * ) &_IsHungAppWindow = GetProcAddress( hUser, "IsHungAppWindow" );
      if( _IsHungAppWindow == NULL )
      {
         return SetLastError( ERROR_PROC_NOT_FOUND ), FALSE;
      }

      // call the function IsHungAppWindow
      *pbHung = _IsHungAppWindow( hWnd );
   }
   else
   {
      DWORD dwThreadId = GetWindowThreadProcessId( hWnd, NULL );

      BOOL ( WINAPI *_IsHungThread ) ( DWORD );

      // found the function IsHungThread
      *( FARPROC * ) &_IsHungThread = GetProcAddress( hUser, "IsHungThread" );
      if( _IsHungThread == NULL )
      {
         return SetLastError( ERROR_PROC_NOT_FOUND ), FALSE;
      }

      // call the function IsHungThread
      *pbHung = _IsHungThread( dwThreadId );
   }

   return TRUE;
}

#if defined( __MINGW32__ )
#pragma GCC diagnostic pop
#endif \
 \
   /* __MINGW32__ */
HB_FUNC( ISAPPHUNG )
{
   BOOL  bIsHung;

   if( IsAppHung( hmg_par_raw_HWND( 1 ), &bIsHung ) )
   {
      hb_retl( bIsHung );
   }
   else
   {
      if( GetLastError() != ERROR_INVALID_PARAMETER )
      {
         MessageBox( NULL, TEXT( "Process not found" ), TEXT( "Warning" ), MB_OK | MB_ICONWARNING );
      }

      hb_retl( HB_FALSE );
   }
}

#ifndef PROCESS_QUERY_LIMITED_INFORMATION
#define PROCESS_QUERY_LIMITED_INFORMATION ( 0x1000 )
#endif

// EmptyWorkingSet( [ ProcessID ] ) ---> lBoolean
HB_FUNC( EMPTYWORKINGSET )
{
   // It removes as many pages as possible from the process working set (clean the working set memory).
   // This operation is useful primarily for testing and tuning.
   DWORD    ProcessID;
   HANDLE   hProcess;

   typedef BOOL ( WINAPI *Func_EmptyWorkingSet ) ( HANDLE );

   static Func_EmptyWorkingSet   pEmptyWorkingSet = NULL;

   if( pEmptyWorkingSet == NULL )
   {
      HMODULE  hLib = LoadLibrary( TEXT( "Kernel32.dll" ) );
      pEmptyWorkingSet = ( Func_EmptyWorkingSet ) wapi_GetProcAddress( hLib, "K32EmptyWorkingSet" );
   }

   if( pEmptyWorkingSet == NULL )
   {
      HMODULE  hLib = LoadLibrary( TEXT( "Psapi.dll" ) );
      pEmptyWorkingSet = ( Func_EmptyWorkingSet ) wapi_GetProcAddress( hLib, "K32EmptyWorkingSet" );
   }

   if( pEmptyWorkingSet != NULL )
   {
      ProcessID = HB_ISNUM( 1 ) ? hmg_par_DWORD( 1 ) : GetCurrentProcessId();

      hProcess = OpenProcess( PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_SET_QUOTA, FALSE, ProcessID );
      if( hProcess != NULL )
      {
         hb_retl( ( BOOL ) pEmptyWorkingSet( hProcess ) );

         CloseHandle( hProcess );
      }
      else
      {
         hb_retl( FALSE );
      }
   }
   else
   {
      hb_retl( FALSE );
   }
}

// Grigory Filatov <gfilatov@gmail.com> HMG 1.1 Experimental Build 10d
HB_FUNC( CLEANPROGRAMMEMORY )
{
   hb_retl( SetProcessWorkingSetSize( GetCurrentProcess(), ( SIZE_T ) - 1, ( SIZE_T ) - 1 ) );
}

// Grigory Filatov <gfilatov@gmail.com> HMG 1.1 Experimental Build 11a
typedef INT ( WINAPI *_GETCOMPACTPATH ) ( LPTSTR pszOut, LPTSTR pszSrc, INT cchMax, DWORD dwFlags );

HB_FUNC( GETCOMPACTPATH )
{
   HINSTANCE   handle = LoadLibrary( TEXT( "shlwapi.dll" ) );

   if( handle )
   {
      _GETCOMPACTPATH   pFunc;
      pFunc = ( _GETCOMPACTPATH ) wapi_GetProcAddress( handle, "PathCompactPathExA" );
      hb_retni( pFunc( ( LPTSTR ) hb_parc( 1 ), ( LPTSTR ) hb_parc( 2 ), hmg_par_INT( 3 ), hmg_par_DWORD( 4 ) ) );
      FreeLibrary( handle );
   }
}

// Jacek Kubica <kubica@wssk.wroc.pl> HMG 1.1 Experimental Build 11a
HB_FUNC( GETSHORTPATHNAME )
{
   HB_SIZE  iRet;

#ifndef UNICODE
   char     buffer[MAX_PATH + 1] = { 0 };
   LPCSTR   lpszLongPath = hb_parc( 1 );
#else
   TCHAR    buffer[MAX_PATH + 1] = { 0 };
   LPCWSTR  lpszLongPath = AnsiToWide( ( char * ) hb_parc( 1 ) );
   LPSTR    pStr;
#endif
   iRet = GetShortPathName( lpszLongPath, buffer, MAX_PATH );
   if( iRet < MAX_PATH )
   {
#ifndef UNICODE
#ifndef __XHARBOUR__
      hb_retni( hb_storclen( buffer, ( HB_SIZE ) iRet, 2 ) );
#else
      hb_storclen( buffer, ( HB_SIZE ) iRet, 2 );
      hb_retni( iRet );
#endif
#else
      pStr = WideToAnsi( buffer );
      hb_retni( hb_storclen( pStr, ( HB_SIZE ) iRet, 2 ) );
      hb_xfree( pStr );
#endif
   }
   else
   {
#ifndef __XHARBOUR__
      hb_retni( hb_storc( "", 2 ) );
#else
      hb_storc( "", 2 );
      hb_retni( 0 );
#endif
   }

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpszLongPath );
#endif
}

HB_FUNC( DRAWTEXT )
{
#ifndef UNICODE
   LPCSTR   lpchText = hb_parc( 2 );
#else
   LPCWSTR  lpchText = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   RECT     rc;

   rc.left = hb_parni( 3 );
   rc.top = hb_parni( 4 );
   rc.right = hb_parni( 5 );
   rc.bottom = hb_parni( 6 );

   DrawText
   (
      hmg_par_raw_HDC( 1 ),         // device context
      lpchText,                     // pointer to string
      ( int ) lstrlen( lpchText ),  // length of  string
      &rc,              // rectangle
      hb_parni( 7 )     // draw style
   );

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpchText );
#endif
}

HB_FUNC( GETTEXTMETRIC )
{
   TEXTMETRIC  tm;
   PHB_ITEM    aMetr = hb_itemArrayNew( 7 );

   if( GetTextMetrics( hmg_par_raw_HDC( 1 ), // handle of device context
   &tm // address of text metrics structure
   ) )
   {
      //tmHeight
      //Specifies the height (ascent + descent) of characters.
      HB_arraySetNL( aMetr, 1, tm.tmHeight );

      //tmAveCharWidth Specifies the average width of characters in the font
      //(generally defined as the width of the letter x).
      //This value does not include the overhang required for bold or italic characters.
      HB_arraySetNL( aMetr, 2, tm.tmAveCharWidth );

      //tmMaxCharWidth
      //Specifies the width of the widest character in the font.
      HB_arraySetNL( aMetr, 3, tm.tmMaxCharWidth );

      //tmAscent
      //Specifies the ascent (units above the base line) of characters.
      HB_arraySetNL( aMetr, 4, tm.tmAscent );

      //tmDescent
      //Specifies the descent (units below the base line) of characters.
      HB_arraySetNL( aMetr, 5, tm.tmDescent );

      //tmInternalLeading
      //Specifies the amount of leading (space) inside the bounds set by the tmHeight member.
      //Accent marks and other diacritical characters may occur in this area.
      //The designer may set this member to zero.
      HB_arraySetNL( aMetr, 6, tm.tmInternalLeading );

      //tmExternalLeading
      //The amount of extra leading (space) that the application adds between rows.
      //Since this area is outside the font, it contains no marks and is not altered by text
      //output calls in either OPAQUE or TRANSPARENT mode.
      //The designer may set this member to zero.
      HB_arraySetNL( aMetr, 7, tm.tmExternalLeading );
   }

   hb_itemReturnRelease( aMetr );
}

HB_FUNC( _GETCLIENTRECT )
{
   RECT  rc;
   HWND  hWnd = hmg_par_raw_HWND( 1 );

   if( IsWindow( hWnd ) )
   {
      GetClientRect( hWnd, &rc );

      hb_itemReturnRelease( Rect2Array( &rc ) );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

// Grigory Filatov <gfilatov@gmail.com> HMG 1.1 Experimental Build 17d
HB_FUNC( ISOEMTEXT )
{
   LPBYTE   pString = ( LPBYTE ) hb_parc( 1 );
   WORD     w = 0, wLen = ( WORD ) hb_parclen( 1 );
   BOOL     bOem = FALSE;

   while( w < wLen && !bOem )
   {
      bOem = pString[w] >= 128 && pString[w] <= 168;
      w++;
   }

   hb_retl( bOem );
}

/*
   Harbour MiniGUI 1.3 Extended (Build 33)
   added by P.Chornyj

   Function GetObjectType()
   ------------------------
   The GetObjectType identifies the type of the specified object.

   Syntax
     GetObjectType( nObject ) --> nType

   Arguments
     nObject is identifies the object

   Returns
     If the function succeeds, the return value identifies the object.
   This value can be one of the following:
     OBJ_PEN         1
     OBJ_BRUSH       2
     OBJ_DC          3
     OBJ_METADC      4
     OBJ_PAL         5
     OBJ_FONT        6
     OBJ_BITMAP      7
     OBJ_REGION      8
     OBJ_METAFILE    9
     OBJ_MEMDC       10
     OBJ_EXTPEN      11
     OBJ_ENHMETADC   12
     OBJ_ENHMETAFILE 13
     OBJ_COLORSPACE  14
 */
HB_FUNC( GETOBJECTTYPE )
{
   hmg_ret_DWORD( GetObjectType( hmg_par_raw_HGDIOBJ( 1 ) ) );
}

/*
   Harbour MiniGUI 1.4 Extended (Build 47)
   added by Grigory Filatov
 */
HB_FUNC( DRAGACCEPTFILES )
{
   DragAcceptFiles( hmg_par_raw_HWND( 1 ), hb_parl( 2 ) );
}

HB_FUNC( DRAGQUERYFILES )
{
   HDROP hDrop = hmg_par_raw_HDROP( 1 );
   UINT  iFiles = DragQueryFile( hDrop, 0xFFFFFFFF, NULL, 0 );
   UINT  i;
   TCHAR bBuffer[250];

#ifdef UNICODE
   LPSTR pStr;
#endif
   hb_reta( iFiles );

   for( i = 0; i < iFiles; i++ )
   {
      DragQueryFile( hDrop, i, ( TCHAR * ) bBuffer, 249 );
#ifndef UNICODE
      HB_STORC( ( TCHAR * ) bBuffer, -1, i + 1 );
#else
      pStr = WideToAnsi( bBuffer );
      HB_STORC( pStr, -1, i + 1 );
      hb_xfree( pStr );
#endif
   }
}

HB_FUNC( DRAGFINISH )
{
   DragFinish( hmg_par_raw_HDROP( 1 ) );
}

HB_FUNC( HMG_CHARSETNAME )
{
#ifdef UNICODE
   hb_retc( WideToAnsi( TEXT( "UNICODE" ) ) );
#else
   hb_retc( "ANSI" );
#endif
}

HB_FUNC( HMG_GETLOCALEINFO )
{
   INT      LCType = hb_parni( 1 );

#ifndef UNICODE
   LPSTR    cText;
#else
   LPWSTR   cText;
   LPSTR    pStr;
#endif
   cText = ( LPTSTR ) hb_xgrab( HB_FILE_TYPE_MAX );

   GetLocaleInfo( LOCALE_USER_DEFAULT, LCType, cText, HB_FILE_TYPE_MAX );

#ifdef UNICODE
   pStr = WideToAnsi( cText );
   hb_retc( pStr );
   hb_xfree( pStr );
#else
   hb_retc( cText );
#endif
   hb_xfree( cText );
}

/*
   --------------------------------------------------------------------------------
   Description:
   Creates the actual 'lnk' file (assumes COM has been initialized).

   Parameters:
   pszTargetfile    - File name of the link's target, must be a non-empty string.
   pszTargetargs    - Command line arguments passed to link's target, may be an empty string.
   pszLinkfile      - File name of the actual link file, must be a non-empty string.
   pszDescription   - Description of the linked item. If this is an empty string, the description is not set.
   iShowmode        - ShowWindow() constant for the link's target:
                        1 (SW_SHOWNORMAL) = Normal window.
                        3 (SW_SHOWMAXIMIZED) = Maximized.
                        7 (SW_SHOWMINNOACTIVE) = Minimized.
                      If zero, the showmode is not set.
   pszCurdir        - Working directory of the active link. If this is an empty string, the directory is not set.
   pszIconfile      - File name of the icon file used for the link.
                      If this is an empty string, the icon is not set.
   iIconindex       - Index of the icon in the icon file. If < 0, the icon is not set.
   wHotKey          - The virtual key code is in the low-order byte,
                      and the modifier flags are in the high-order byte.

   Returns:
   HRESULT value >= 0 for success, < 0 for failure.
   --------------------------------------------------------------------------------
*/
#ifndef UNICODE
static HRESULT CreateShortCut
   (
      LPSTR pszTargetfile, LPSTR pszTargetargs, LPSTR pszLinkfile, LPSTR pszDescription, int iShowmode, LPSTR pszCurdir, LPSTR pszIconfile, int iIconindex,
         WORD wHotKey
   )
#else
static HRESULT CreateShortCut
   (
      LPWSTR pszTargetfile, LPWSTR pszTargetargs, LPWSTR pszLinkfile, LPWSTR pszDescription, int iShowmode, LPWSTR pszCurdir, LPWSTR pszIconfile, int iIconindex,
         WORD wHotKey
   )
#endif
{
   HRESULT        hRes = E_INVALIDARG;             // Default return value for invalid arguments
   IShellLink     *pShellLink = NULL;              // Pointer to IShellLink object
   IPersistFile   *pPersistFile = NULL;            // Pointer to IPersistFile object
   WCHAR          wszLinkfile[MAX_PATH] = { 0 };   // Buffer for wide-char link file name

   // Validate mandatory parameters
   if( pszTargetfile && *pszTargetfile && pszLinkfile && *pszLinkfile )
   {
      // Create IShellLink instance
      hRes = CoCreateInstance( &CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER, &IID_IShellLink, ( LPVOID * ) &pShellLink );

      if( SUCCEEDED( hRes ) && pShellLink )
      {
         // Set link properties
         pShellLink->lpVtbl->SetPath( pShellLink, pszTargetfile );
         pShellLink->lpVtbl->SetArguments( pShellLink, pszTargetargs );

         if( pszDescription && *pszDescription )
         {
            pShellLink->lpVtbl->SetDescription( pShellLink, pszDescription );
         }
         if( iShowmode > 0 )
         {
            pShellLink->lpVtbl->SetShowCmd( pShellLink, iShowmode );
         }
         if( pszCurdir && *pszCurdir )
         {
            pShellLink->lpVtbl->SetWorkingDirectory( pShellLink, pszCurdir );
         }
         if( pszIconfile && *pszIconfile && iIconindex >= 0 )
         {
            pShellLink->lpVtbl->SetIconLocation( pShellLink, pszIconfile, iIconindex );
         }
         if( wHotKey != 0 )
         {
            pShellLink->lpVtbl->SetHotkey( pShellLink, wHotKey );
         }

         // Save the link using IPersistFile
         hRes = pShellLink->lpVtbl->QueryInterface( pShellLink, &IID_IPersistFile, ( LPVOID * ) &pPersistFile );

         if( SUCCEEDED( hRes ) && pPersistFile )
         {
#ifndef UNICODE
            MultiByteToWideChar( CP_ACP, 0, pszLinkfile, -1, wszLinkfile, MAX_PATH );
#else
            lstrcpy( wszLinkfile, pszLinkfile );
#endif
            hRes = pPersistFile->lpVtbl->Save( pPersistFile, wszLinkfile, TRUE );
            pPersistFile->lpVtbl->Release( pPersistFile );
         }

         // Release IShellLink object
         pShellLink->lpVtbl->Release( pShellLink );
      }
   }
   return hRes;
}

/***************************************************************************/
#if defined( __BORLANDC__ ) && ! defined( _WIN64 )
#pragma warn -prc          /* suggest parentheses to clarify precedence */
#endif

HB_FUNC( C_CREATELINK )
{
   int      iShowmode;     /* <Showmode> (optional) */
   int      iIconindex;    /* <Iconindex> (optional) */
   WORD     wHotKey;       /* Virtual key code (optional) */
   BYTE     uVirtualKeyCode;
   BYTE     uModifiers;    /* Modifier flags */
   HRESULT  hRes;          /* Result of calling COM functions */

#ifndef UNICODE
   LPSTR    szTargetfile;  /* <Targetfile> */
   LPSTR    szTargetargs;  /* <Targetargs> */
   LPSTR    szLinkfile;    /* <Linkfile> */
   LPSTR    szDescription; /* <Description> */
   LPSTR    szCurdir;      /* <Curdir> (optional) */
   LPSTR    szIconfile;    /* <Iconfile> (optional) */

   // Assign parameters with fallback values for optional fields
   szTargetfile = ( char * ) hb_parc( 1 );
   szTargetargs = HB_ISCHAR( 2 ) ? ( char * ) hb_parc( 2 ) : "";
   szLinkfile = ( char * ) hb_parc( 3 );
   szDescription = HB_ISCHAR( 4 ) ? ( char * ) hb_parc( 4 ) : "";
   szCurdir = HB_ISCHAR( 6 ) ? ( char * ) hb_parc( 6 ) : "";
   szIconfile = HB_ISCHAR( 7 ) ? ( char * ) hb_parc( 7 ) : "";
#else
   LPWSTR   szTargetfile;  /* <Targetfile> */
   LPWSTR   szTargetargs;  /* <Targetargs> */
   LPWSTR   szLinkfile;    /* <Linkfile> */
   LPWSTR   szDescription; /* <Description> */
   LPWSTR   szCurdir;      /* <Curdir> (optional) */
   LPWSTR   szIconfile;    /* <Iconfile> (optional) */

   // Convert ANSI strings to wide strings for Unicode builds
   szTargetfile = AnsiToWide( ( char * ) hb_parc( 1 ) );
   szTargetargs = HB_ISCHAR( 2 ) ? AnsiToWide( ( char * ) hb_parc( 2 ) ) : TEXT( "" );
   szLinkfile = AnsiToWide( ( char * ) hb_parc( 3 ) );
   szDescription = HB_ISCHAR( 4 ) ? AnsiToWide( ( char * ) hb_parc( 4 ) ) : TEXT( "" );
   szCurdir = HB_ISCHAR( 6 ) ? AnsiToWide( ( char * ) hb_parc( 6 ) ) : TEXT( "" );
   szIconfile = HB_ISCHAR( 7 ) ? AnsiToWide( ( char * ) hb_parc( 7 ) ) : TEXT( "" );
#endif

   // Retrieve optional numeric parameters with defaults
   iShowmode = hb_parnidef( 5, 0 );
   iIconindex = hb_parnidef( 8, 0 );

   // Retrieve virtual key and modifier byte parameters for hotkey
   uVirtualKeyCode = hmg_par_BYTE( 9 );
   uModifiers = hmg_par_BYTE( 10 );
   wHotKey = MAKEWORD( uVirtualKeyCode, uModifiers );

   // Initialize COM library
   hRes = CoInitialize( NULL );
   if( SUCCEEDED( hRes ) )
   {
      // Call CreateShortCut to create the shortcut file
      hRes = CreateShortCut
         (
            szTargetfile,  /* Target file */
            szTargetargs,  /* Target arguments */
            szLinkfile,    /* Shortcut filename */
            szDescription, /* Shortcut description */
            iShowmode,     /* Showmode constant */
            szCurdir,      /* Working directory for linked file */
            szIconfile,    /* Icon file shown for the link */
            iIconindex,    /* Index of icon in the file */
            wHotKey        /* Virtual key code */
         );

      // Return the HRESULT of the operation
      hmg_ret_HRESULT( hRes );

      // Uninitialize COM library
      CoUninitialize();
   }
   else
   {
      // Return the HRESULT if COM initialization failed
      hmg_ret_HRESULT( hRes );
   }
}

#ifdef __XCC__
char *itoa( int n, char s[], int base )
{
   int   d = n % base;
   int   r = n / base;

   if( n < 0 )
   {
      *s++ = '-';
      d = -d;
      r = -r;
   }

   if( r )
   {
      s = itoa( r, s, base );
   }

   *s++ = "0123456789abcdefghijklmnopqrstuvwxyz"[d];
   *s = 0;

   return s;
}
#endif /* __XCC__ */
