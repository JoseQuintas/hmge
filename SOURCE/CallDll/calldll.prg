/*
 * Harbour Project source code:
 * CALLDLL compatibility library.
 *
 * Copyright 2010 Viktor Szakats (harbour syenar.net)
 * www - https://harbour.github.io/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.txt.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include "hbdyn.ch"

STATIC s_hDLL := { => }
STATIC s_mutex := hb_mutexCreate()

PROCEDURE UnloadAllDll()

   hb_mutexLock( s_mutex )
   s_hDLL := { => }
   hb_mutexUnlock( s_mutex )

RETURN

//       HMG_CallDLL( cLibName, [ nRetType ] , cFuncName [, Arg1, ..., ArgN ] ) ---> xRetValue
FUNCTION HMG_CallDLL( cLibName, nRetType, cFuncName, ... )

   LOCAL nEncoding := iif( HMG_IsCurrentCodePageUnicode(), HB_DYN_ENC_UTF16, HB_DYN_ENC_ASCII )
   LOCAL pLibrary

   IF HB_ISSTRING( cFuncName ) .AND. HB_ISSTRING( cLibName )
      hb_mutexLock( s_mutex )

      IF !( cLibName $ s_hDLL )
         s_hDLL[ cLibName ] := hb_libLoad( cLibName )
      ENDIF

      pLibrary := s_hDLL[ cLibName ]

      hb_mutexUnlock( s_mutex )

      IF .NOT. HB_ISNUMERIC( nRetType )
         nRetType := HB_DYN_CTYPE_DEFAULT
      ENDIF

      cFuncName := AllTrim( cFuncName )

      DO CASE
      CASE HMG_IsCurrentCodePageUnicode() == .T. .AND. HMG_IsFuncDLL( pLibrary, cFuncName + "W" )
         cFuncName := cFuncName + "W"
      CASE HMG_IsCurrentCodePageUnicode() == .F. .AND. HMG_IsFuncDLL( pLibrary, cFuncName + "A" )
         cFuncName := cFuncName + "A"
      ENDCASE

      RETURN hb_DynCall( { cFuncName, pLibrary, hb_bitOr( HB_DYN_CALLCONV_STDCALL, nRetType, nEncoding, HB_DYC_OPT_NULLTERM ) }, ... )
   ENDIF

RETURN NIL

FUNCTION HMG_IsCurrentCodePageUnicode()
RETURN ( "UTF8" $ Set( _SET_CODEPAGE ) )

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

//        HMG_IsFuncDLL ( pLibDLL | cLibName, cFuncName ) ---> Boolean
HB_FUNC ( HMG_ISFUNCDLL )
{
   HMODULE hModule;
   BOOL bRelease;
   char * cFuncName;

   if ( HB_ISCHAR( 1 ) )
   {  hModule = LoadLibrary( ( char * ) hb_parc( 1 ) );
      bRelease = TRUE;
   }
   else
   {  hModule = ( HMODULE ) hb_libHandle( hb_param( 1, HB_IT_ANY ) );
      bRelease = FALSE;
   }

   cFuncName = ( char * ) hb_parc( 2 );

   hb_retl( GetProcAddress( hModule, cFuncName ) ? TRUE : FALSE );

   if( bRelease && hModule )
      FreeLibrary( hModule );
}

#pragma ENDDUMP
