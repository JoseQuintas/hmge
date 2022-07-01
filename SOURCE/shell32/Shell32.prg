// ===========================================================================
// Shell32.PRG        (c) 2004, Grigory Filatov
// ===========================================================================
//
//   Created   : 08.09.04
//   Extended  : 28.04.07
//   Section   : Shell Extensions
//
//   Windows ShellAPI provides functions to implement:
//   · The drag-drop feature
//   · Associations (used) to find and start applications
//   · Extraction of icons from executable files
//   · Explorer File operation
//
//
// ===========================================================================

#include "Shell32.ch"
#include "common.ch"

// ===========================================================================
// Function ShFolderDelete( hParentWnd, acFolder, lSilent )
//
// Purpose:
//  Use the Windows ShellAPI function to delete folder(s) with all its files and
//  subdirectories.
//  acFolder can be an Array of FolderName string, or a single FolderName string.
//  If lSilent is TRUE (default), you can not an any confirmation
//
// ===========================================================================
FUNCTION SHFolderDelete( hWnd, acFolder, lSilent )

   LOCAL nFlag := 0

   DEFAULT hWnd TO GetActiveWindow()

   IF lSilent == NIL .OR. lSilent
      nFlag := FOF_NOCONFIRMATION + FOF_SILENT
   ENDIF

RETURN ( ShellFiles( hWnd, acFolder, , FO_DELETE, nFlag ) == 0 )


// ===========================================================================
// Function ShFileDelete( hParentWnd, aFiles, lRecycle )
//
// Purpose:
//  Use the Windows ShellAPI function to delete file(s).
//  aFiles can be an Array of FileName strings, or a single FileName string.
//  If lRecycle is TRUE (default), deleted files are moved into the recycle Bin
//
// ===========================================================================
FUNCTION SHFileDelete( hWnd, acFiles, lRecycle )

   LOCAL nFlag := 0

   DEFAULT hWnd TO GetActiveWindow()

   IF lRecycle == NIL .OR. lRecycle
      nFlag := FOF_ALLOWUNDO
   ENDIF

RETURN ( ShellFiles( hWnd, acFiles, , FO_DELETE, nFlag ) == 0 )


// ===========================================================================
// Function ShellFile( hParentWnd, aFiles, aTarget, nFunc, nFlag )
//
// Purpose:
// Performs a copy, move, rename, or delete operation on a file system object.
// Parameters:
//   aFiles  is an Array of Source-Filenamestrings, or a single Filenamestring
//   aTarget is an Array of Target-Filenamestrings, or a single Filenamestring
//   nFunc   determines the action on the files:
//           FO_MOVE, FO_COPY, FO_DELETE, FO_RENAME
//   fFlag   Option Flag ( see the file SHELL32.CH )
//
// ===========================================================================
FUNCTION ShellFiles( hWnd, acFiles, acTarget, wFunc, fFlag )

   LOCAL cTemp

   // Parent Window
   //
   hb_default( @hWnd, GetActiveWindow() )

   // Operation Flag
   //
   IF wFunc == NIL
      wFunc := FO_DELETE
   ENDIF

   // Options Flag
   //
   IF fFlag == NIL
      fFlag := FOF_ALLOWUNDO
   ENDIF

   // SourceFiles, convert Array to String
   //
   DEFAULT acFiles TO Chr( 0 )

   IF hb_IsArray( acFiles )
      cTemp :=  ""
      AEval( acFiles, {| x | cTemp += x + Chr( 0 ) } )
      acFiles := cTemp
   ENDIF
   acFiles += Chr( 0 )

   // TargetFiles, convert Array to String
   //
   DEFAULT acTarget TO Chr( 0 )

   IF hb_IsArray( acTarget )
      cTemp := ""
      AEval( acTarget, {| x | cTemp += x + Chr( 0 ) } )
      acTarget := cTemp
   ENDIF
   acTarget += Chr( 0 )

   // call SHFileOperation
   //
RETURN ShellFileOperation( hWnd, acFiles, acTarget, wFunc, fFlag )


#pragma BEGINDUMP

#include <mgdefs.h>
#include <shellapi.h>

#ifdef UNICODE
   LPWSTR AnsiToWide( LPCSTR );
#endif

HB_FUNC ( SHELLFILEOPERATION )
{
#ifndef UNICODE
   LPCSTR lpFrom = ( LPCSTR ) hb_parc( 2 );
   LPCSTR lpTo = ( LPCSTR ) hb_parc( 3 );
#else
   LPCWSTR lpFrom = AnsiToWide( ( char * ) hb_parc( 2 ) );
   LPCWSTR lpTo = AnsiToWide( ( char * ) hb_parc( 3 ) );
#endif
   SHFILEOPSTRUCT sh;

   sh.hwnd   = hmg_par_raw_HWND( 1 );
   sh.pFrom  = lpFrom;
   sh.pTo    = lpTo;
   sh.wFunc  = hmg_par_UINT( 4 );
   sh.fFlags = hmg_par_WORD( 5 );
   sh.hNameMappings = 0;
   sh.lpszProgressTitle = NULL;

   hmg_ret_NINT( SHFileOperation( &sh ) );

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpFrom );
   hb_xfree( ( TCHAR * ) lpTo );
#endif
}

#pragma ENDDUMP
