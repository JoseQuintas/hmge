/*
 * HMG - Harbour Win32 GUI library
 *
 * Copyright 2014 Dr. Claudio Soto <srvet@adinet.com.uy>
 *
 * The double click allow you terminate the process
 *
 * Used functions:
   - GetCurrentProcessId() --> return nProcessID
   - EnumProcessesID () ---> return array { nProcessID1, nProcessID2, ... }
   - GetProcessName ( [ nProcessID ] ) --> return cProcessName
   - GetProcessFullName ( [ nProcessID ] ) --> return cProcessFullName
   - GetWindowThreadProcessId (hWnd, @nThread, @nProcessID)
   - IsWow64Process ( [ nProcessID ] ) --> return lBoolean
     - return TRUE  if a 32-bit application is running under 64-bit Windows (WOW64)
     - return FALSE if a 32-bit application is running under 32-bit Windows
     - return FALSE if a 64-bit application is running under 64-bit Windows
     - WOW64 is the x86 emulator that allows 32-bit Windows-based applications to running on 64-bit Windows
*/

*************************************************************************************
* Attention: to detect processes 32 and 64 bits you should compiling with HMG-64 bits
*************************************************************************************

#include "common.ch"

#define INFINITE        0xFFFFFFFF

// Waits until the specified object is in the signaled state or the time-out interval elapses
FUNCTION WaitForSingleObject( hProcess, nWait )

   DEFAULT nWait TO INFINITE

RETURN wapi_WaitForSingleObject( win_N2P( hProcess ), nWait )


#pragma BEGINDUMP

#include <mgdefs.h>
#include "hbapiitm.h"

#ifdef UNICODE
LPSTR WideToAnsi( LPWSTR );
#endif

extern HB_PTRUINT wapi_GetProcAddress( HMODULE hModule, LPCSTR lpProcName );

//        IsWow64Process ( [ nProcessID ] ) --> return lBoolean
HB_FUNC( ISWOW64PROCESS )
{
   typedef BOOL ( WINAPI * LPFN_ISWOW64PROCESS )( HANDLE, PBOOL );
   static LPFN_ISWOW64PROCESS fnIsWow64Process = NULL;

   BOOL IsWow64 = FALSE;

   if( fnIsWow64Process == NULL )
      fnIsWow64Process = ( LPFN_ISWOW64PROCESS ) wapi_GetProcAddress( GetModuleHandle( "kernel32" ), "IsWow64Process" );

   if( fnIsWow64Process != NULL )
   {
      if( HB_ISNUM( 1 ) == FALSE )
         fnIsWow64Process( GetCurrentProcess(), &IsWow64 );
      else
      {
         DWORD  ProcessID = hmg_par_DWORD( 1 );
         HANDLE hProcess  = OpenProcess( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, ProcessID );
         if( hProcess != NULL )
         {
            fnIsWow64Process( hProcess, &IsWow64 );
            CloseHandle( hProcess );
         }
      }
   }
   hb_retl( IsWow64 );
}

//        GetCurrentProcessId() --> return nProcessID
HB_FUNC( GETCURRENTPROCESSID )
{
   hmg_ret_NINT( GetCurrentProcessId() );
}

//        EnumProcessesID () ---> return array { nProcessID1, nProcessID2, ... }
HB_FUNC( ENUMPROCESSESID )
{
   typedef BOOL ( WINAPI * Func_EnumProcesses )( DWORD *, DWORD, DWORD * );
   static Func_EnumProcesses pEnumProcesses = NULL;

   DWORD        aProcessesID[ 1024 ], cbNeeded, nProcesses;
   unsigned int i;

   PHB_ITEM pArray = hb_itemArrayNew( 0 );

   if( pEnumProcesses == NULL )
   {
      HMODULE hLib = LoadLibrary( TEXT( "Psapi.dll" ) );
      pEnumProcesses = ( Func_EnumProcesses ) wapi_GetProcAddress( hLib, "EnumProcesses" );
   }

   if( pEnumProcesses == NULL )
      return;

   // Get the list of process identifiers.
   if( pEnumProcesses( aProcessesID, sizeof( aProcessesID ), &cbNeeded ) == FALSE )
      return;

   // Calculate how many process identifiers were returned.
   nProcesses = cbNeeded / sizeof( DWORD );

   for( i = 0; i < nProcesses; i++ )
   {
      if( aProcessesID[ i ] != 0 )
      {
         PHB_ITEM pItem = hb_itemPutNL( NULL, ( LONG ) aProcessesID[ i ] );
         hb_arrayAddForward( pArray, pItem );
         hb_itemRelease( pItem );
      }
   }

   hb_itemReturnRelease( pArray );
}

//        GetWindowThreadProcessId (hWnd, @nThread, @nProcessID)
HB_FUNC( GETWINDOWTHREADPROCESSID )
{
   DWORD nThread, nProcessID;

   nThread = GetWindowThreadProcessId( hmg_par_raw_HWND( 1 ), &nProcessID );

   if( HB_ISBYREF( 2 ) )
      hb_storni( nThread, 2 );
   if( HB_ISBYREF( 3 ) )
      hb_storni( nProcessID, 3 );
}

//        GetProcessName ( [ nProcessID ] ) --> return cProcessName
HB_FUNC( GETPROCESSNAME )
{
   typedef BOOL ( WINAPI * Func_EnumProcessModules )( HANDLE, HMODULE *, DWORD, LPDWORD );
   static Func_EnumProcessModules pEnumProcessModules = NULL;

   typedef DWORD ( WINAPI * Func_GetModuleBaseName )( HANDLE, HMODULE, LPTSTR, DWORD );
   static Func_GetModuleBaseName pGetModuleBaseName = NULL;

#ifdef UNICODE
   LPSTR pStr;
#endif
   DWORD  ProcessID = HB_ISNUM( 1 ) ? hmg_par_DWORD( 1 ) : GetCurrentProcessId();
   TCHAR  cProcessName[ MAX_PATH ] = _TEXT( "" );
   HANDLE hProcess;

   if( pEnumProcessModules == NULL )
   {
      HMODULE hLib = LoadLibrary( _TEXT( "Psapi.dll" ) );
      pEnumProcessModules = ( Func_EnumProcessModules ) wapi_GetProcAddress( hLib, "EnumProcessModules" );
   }

   if( pEnumProcessModules == NULL )
      return;

   if( pGetModuleBaseName == NULL )
   {
      HMODULE hLib = LoadLibrary( _TEXT( "Psapi.dll" ) );

       #ifdef UNICODE
      pGetModuleBaseName = ( Func_GetModuleBaseName ) wapi_GetProcAddress( hLib, "GetModuleBaseNameW" );
       #else
      pGetModuleBaseName = ( Func_GetModuleBaseName ) wapi_GetProcAddress( hLib, "GetModuleBaseNameA" );
       #endif
   }

   if( pGetModuleBaseName == NULL )
      return;

   hProcess = OpenProcess( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, ProcessID );
   if( hProcess != NULL )
   {
      HMODULE hMod;
      DWORD   cbNeeded;
      if( pEnumProcessModules( hProcess, &hMod, sizeof( hMod ), &cbNeeded ) )
         pGetModuleBaseName( hProcess, hMod, cProcessName, sizeof( cProcessName ) / sizeof( TCHAR ) );

      CloseHandle( hProcess );
#ifndef UNICODE
      hb_retc( cProcessName );
#else
      pStr = WideToAnsi( cProcessName );
      hb_retc( pStr );
      hb_xfree( pStr );
#endif
   }
}

//        GetProcessFullName ( [ nProcessID ] ) --> return cProcessFullName
HB_FUNC( GETPROCESSFULLNAME )
{
   typedef BOOL ( WINAPI * Func_EnumProcessModules )( HANDLE, HMODULE *, DWORD, LPDWORD );
   static Func_EnumProcessModules pEnumProcessModules = NULL;

   typedef DWORD ( WINAPI * Func_GetModuleFileNameEx )( HANDLE, HMODULE, LPTSTR, DWORD );
   static Func_GetModuleFileNameEx pGetModuleFileNameEx = NULL;

#ifdef UNICODE
   LPSTR pStr;
#endif
   DWORD  ProcessID = HB_ISNUM( 1 ) ? hmg_par_DWORD( 1 ) : GetCurrentProcessId();
   TCHAR  cProcessFullName[ MAX_PATH ] = _TEXT( "" );
   HANDLE hProcess;

   if( pEnumProcessModules == NULL )
   {
      HMODULE hLib = LoadLibrary( _TEXT( "Psapi.dll" ) );
      pEnumProcessModules = ( Func_EnumProcessModules ) wapi_GetProcAddress( hLib, "EnumProcessModules" );
   }

   if( pEnumProcessModules == NULL )
      return;

   if( pGetModuleFileNameEx == NULL )
   {
      HMODULE hLib = LoadLibrary( _TEXT( "Psapi.dll" ) );

       #ifdef UNICODE
      pGetModuleFileNameEx = ( Func_GetModuleFileNameEx ) wapi_GetProcAddress( hLib, "GetModuleFileNameExW" );
       #else
      pGetModuleFileNameEx = ( Func_GetModuleFileNameEx ) wapi_GetProcAddress( hLib, "GetModuleFileNameExA" );
       #endif
   }

   if( pGetModuleFileNameEx == NULL )
      return;

   hProcess = OpenProcess( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, ProcessID );
   if( hProcess != NULL )
   {
      HMODULE hMod;
      DWORD   cbNeeded;
      if( pEnumProcessModules( hProcess, &hMod, sizeof( hMod ), &cbNeeded ) )
         pGetModuleFileNameEx( hProcess, hMod, cProcessFullName, sizeof( cProcessFullName ) / sizeof( TCHAR ) );

      CloseHandle( hProcess );
#ifndef UNICODE
      hb_retc( cProcessFullName );
#else
      pStr = WideToAnsi( cProcessFullName );
      hb_retc( pStr );
      hb_xfree( pStr );
#endif
   }
}

//        TerminateProcess ( [ nProcessID ] , [ nExitCode ] )
HB_FUNC( TERMINATEPROCESS )
{
   DWORD  ProcessID = HB_ISNUM( 1 ) ? hmg_par_DWORD( 1 ) : GetCurrentProcessId();
   UINT   uExitCode = hmg_par_UINT( 2 );
   HANDLE hProcess  = OpenProcess( PROCESS_TERMINATE, FALSE, ProcessID );

   if( hProcess != NULL )
   {
      if( TerminateProcess( hProcess, uExitCode ) == FALSE )
         CloseHandle( hProcess );
   }
}

#pragma ENDDUMP
