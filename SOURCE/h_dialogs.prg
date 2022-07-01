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

#ifdef __XHARBOUR__
#define __SYSDATA__
#endif
#include 'minigui.ch'
#include "i_winuser.ch"

*-----------------------------------------------------------------------------*
FUNCTION GetColor( aInitColor, aCustomColors, nFlags )
*-----------------------------------------------------------------------------*
   LOCAL aRetVal [3]
   LOCAL nColor, nInitColor, i

   IF IsArrayRGB ( aInitColor )
      nInitColor := RGB ( aInitColor [1], aInitColor [2], aInitColor [3] )
   ENDIF

   IF ISARRAY ( aCustomColors )
      /* aCustomColors parameter must be the array with 16 RGB-colors elements if it is defined */
      ASize ( aCustomColors, 16 )
      FOR i = 1 TO 16
          IF IsArrayRGB ( aCustomColors [i] )
             aCustomColors [i] := RGB ( aCustomColors [i][1], aCustomColors [i][2], aCustomColors [i][3] )
          ELSEIF ! ISNUMERIC ( aCustomColors [i] )
             aCustomColors [i] := GetSysColor ( COLOR_BTNFACE )
          ENDIF
      NEXT
   ENDIF

   IF ISLOGICAL ( nFlags )  // for HMG compatibility
      IF nFlags == .F.
         #define CC_RGBINIT				1
         #define CC_PREVENTFULLOPEN		4
         #define CC_ANYCOLOR			256
         nFlags := hb_BitOr ( CC_ANYCOLOR, CC_PREVENTFULLOPEN, CC_RGBINIT )
      ELSE
         /* default nFlags value is hb_BitOr( CC_ANYCOLOR, CC_FULLOPEN, CC_RGBINIT ) */
         nFlags := NIL
      ENDIF
   ENDIF

   IF ( nColor := ChooseColor ( NIL, nInitColor, @aCustomColors, nFlags ) ) != -1
      aRetVal := nRGB2Arr ( nColor )
   ENDIF

RETURN aRetVal

*-----------------------------------------------------------------------------*
FUNCTION GetFolder( cTitle, cInitPath, nFlags, lNewFolderButton, nFolderType ) // JK HMG 1.0 Experimental Build 8
*-----------------------------------------------------------------------------*
RETURN C_BrowseForFolder( NIL, cTitle, ;
   hb_defaultValue( nFlags, BIF_USENEWUI + BIF_VALIDATE ) + ;
   iif( hb_defaultValue( lNewFolderButton, .T. ), 0, BIF_NONEWFOLDERBUTTON ), nFolderType, cInitPath )

*-----------------------------------------------------------------------------*
FUNCTION BrowseForFolder( nFolderType, nFlags, cTitle, cInitPath ) // Contributed By Ryszard Rylko
*-----------------------------------------------------------------------------*
RETURN C_BrowseForFolder( NIL, cTitle, ;
   hb_defaultValue( nFlags, hb_BitOr( BIF_NEWDIALOGSTYLE, BIF_EDITBOX, BIF_VALIDATE ) ), nFolderType, cInitPath )

#ifndef __XHARBOUR__
#include "hbwin.ch"

*-----------------------------------------------------------------------------*
FUNCTION GetFile( acFilter, cTitle, cInitDir, lMultiSelect, lNoChangeDirectory, nFilterIndex )
*-----------------------------------------------------------------------------*
   LOCAL cRet, aTmp, xRet, i
   LOCAL cPath, nTmp
   LOCAL cFilter := ""
   LOCAL nFlags := WIN_OFN_EXPLORER

   hb_default( @lMultiSelect, .F. )
   hb_default( @lNoChangeDirectory, .F. )

   IF lMultiSelect
      nFlags += WIN_OFN_ALLOWMULTISELECT
   ENDIF

   IF lNoChangeDirectory
      nFlags += WIN_OFN_NOCHANGEDIR
   ENDIF

   IF ISARRAY( acFilter )
      AEval( acFilter, { | x | cFilter += x [1] + Chr( 0 ) + x [2] + Chr( 0 ) } )
      cFilter += Chr( 0 )
   ENDIF

/* win_GetOpenFileName( [[@]<nFlags>], [<cTitle>], [<cInitDir>], [<cDefExt>], ;
 *                      [<acFilter>], [[@]<nFilterIndex>], [<nBufferSize>], [<cDefName>] )
 *    --> <cFilePath> | <cPath> + e"\0" + <cFile1> [ + e"\0" + <cFileN> ] | ""
 */
   cRet := win_GetOpenFileName( @nFlags, cTitle, cInitDir, /*cDefExt*/, cFilter, @nFilterIndex, /*nBufferSize*/, /*cDefName*/ )

   IF hb_bitAnd( nFlags, WIN_OFN_ALLOWMULTISELECT ) != 0
      xRet := {}
      IF ! Empty( aTmp := hb_ATokens( cRet, Chr( 0 ) ) )
         IF ( nTmp := Len( aTmp ) ) == 1
            IF ! Empty( aTmp[ 1 ] )
               xRet := { aTmp[ 1 ] }
            ENDIF
         ELSE
            cPath := aTmp[ 1 ]
            FOR i := 2 TO nTmp
               AAdd( xRet, cPath + "\" + aTmp[ i ] )
            NEXT
         ENDIF
      ENDIF
   ELSE
      xRet := cRet
   ENDIF

RETURN xRet

*-----------------------------------------------------------------------------*
FUNCTION Putfile( acFilter, cTitle, cInitDir, lNoChangeCurDir, cDefName, nFilterIndex, lPromptOverwrite )
*-----------------------------------------------------------------------------*
   LOCAL cRet, aTmp, xRet, i, cPath
   LOCAL cFilter := "", cDefExt := ""
   LOCAL nFlags := WIN_OFN_EXPLORER

   hb_default( @nFilterIndex, 1 )
   hb_default( @lNoChangeCurDir, .F. )
   hb_default( @lPromptOverwrite, .F. )

   IF lNoChangeCurDir
      nFlags += WIN_OFN_NOCHANGEDIR
   ENDIF

   IF lPromptOverwrite
      nFlags += WIN_OFN_OVERWRITEPROMPT
   ENDIF

   IF ISARRAY( acFilter )
      AEval( acFilter, { | x | cFilter += x [1] + Chr( 0 ) + x [2] + Chr( 0 ) } )
      cFilter += Chr( 0 )
   ENDIF

/* win_GetSaveFileName( [[@]<nFlags>], [<cTitle>], [<cInitDir>], [<cDefExt>], ;
 *                      [<acFilter>], [[@]<nFilterIndex>], [<nBufferSize>], [<cDefName>] )
 *    --> <cFilePath> | <cPath> + e"\0" + <cFile1> [ + e"\0" + <cFileN> ] | ""
 */
   cRet := win_GetSaveFileName( @nFlags, cTitle, cInitDir, cDefExt, acFilter, @nFilterIndex, /*nBufferSize*/, cDefName )

   IF hb_bitAnd( nFlags, WIN_OFN_ALLOWMULTISELECT ) != 0
      xRet := {}
      IF ! Empty( aTmp := hb_ATokens( cRet, Chr( 0 ) ) )
         cPath := aTmp[ 1 ]
         FOR i := 2 TO Len( aTmp )
            AAdd( xRet, cPath + "\" + aTmp[ i ] )
         NEXT
      ENDIF
   ELSE
      xRet := cRet
   ENDIF

RETURN xRet

#else

/*
 *  File Open/Save Dialog Constants
 */
#define OFN_READONLY                      1
#define OFN_OVERWRITEPROMPT               2
#define OFN_HIDEREADONLY                  4
#define OFN_NOCHANGEDIR                   8
#define OFN_SHOWHELP                     16
#define OFN_ENABLEHOOK                   32
#define OFN_ENABLETEMPLATE               64
#define OFN_ENABLETEMPLATEHANDLE        128
#define OFN_NOVALIDATE                  256
#define OFN_ALLOWMULTISELECT            512
#define OFN_EXTENSIONDIFFERENT         1024
#define OFN_PATHMUSTEXIST              2048
#define OFN_FILEMUSTEXIST              4096
#define OFN_CREATEPROMPT               8192
#define OFN_SHAREAWARE                16384
#define OFN_NOREADONLYRETURN          32768
#define OFN_NOTESTFILECREATE          65536
#define OFN_NONETWORKBUTTON          131072
#define OFN_NOLONGNAMES              262144  // force no long names for 4.x modules
#define OFN_EXPLORER                 524288  // new look commdlg
#define OFN_NODEREFERENCELINKS      1048576
#define OFN_LONGNAMES               2097152  // force long names for 3.x modules
#define OFN_ENABLEINCLUDENOTIFY     4194304  // send include message to callback
#define OFN_ENABLESIZING            8388608
#define OFN_DONTADDTORECENT        33554432
#define OFN_FORCESHOWHIDDEN       268435456  // Show All files including System and hidden files

*-----------------------------------------------------------------------------*
FUNCTION GetFile( aFilter, cTitle, cIniDir, lMultiSelect, lNoChangeDirectory, nIndex )
*-----------------------------------------------------------------------------*
   LOCAL cPath, cDefExt := ""
   LOCAL aFiles, cRet, cFile, n, x, c := ''
   LOCAL nFlags := OFN_EXPLORER

   hb_default( @lMultiSelect, .F. )
   hb_default( @lNoChangeDirectory, .F. )

   IF lMultiSelect
      nFlags += OFN_ALLOWMULTISELECT
   ENDIF
   IF lNoChangeDirectory
      nFlags += OFN_NOCHANGEDIR
   ENDIF

   IF aFilter == NIL
      aFilter := {}
   ENDIF
   IF HB_ISARRAY( aFilter )
      FOR n := 1 TO Len( aFilter )
         c += aFilter[ n ][ 1 ] + Chr( 0 ) + aFilter[ n ][ 2 ] + Chr( 0 )
         c += Chr( 0 )
      NEXT
   ENDIF

   IF WIN_AND( nFlags, OFN_ALLOWMULTISELECT ) > 0
      cFile := Space( 32000 )
   ELSE
      cFile := PadR( Space( 254 ), 255, Chr( 0 ) )
   ENDIF
/*
Wvt_GetOpenFileName( hWnd, @cPath, cTitle, aFilter, nFlags, cInitDir, cDefExt, nIndex )

hWnd:     Handle to parent window
cPath:    (optional) if OFN_ALLOWMULTISELECT the path is stored
cTitle:   Window Title
aFilter:  Array of Files Types i.e. { {'Data Bases','*.dbf'},{'Clipper','*.prg'} }
nFlags:   OFN_* values default to OFN_EXPLORER
cInitDir: Initial directory
cDefExt:  Default Extension i.e. 'DBF'
nIndex:   Index position of types

Returns:  If OFN_ALLOWMULTISELECT
              Array of files selected
          else
              FileName
          endif
*/
   cRet := WVT__GetOpenFileName( NIL, @cFile, cTitle, c, nFlags, cIniDir, cDefExt, @nIndex )

   IF WIN_AND( nFlags, OFN_ALLOWMULTISELECT ) > 0
      n := At( Chr( 0 ) + Chr( 0 ), cFile )
      cFile := Left( cFile, n )
      aFiles := {}
      IF n == 0 // no double chr(0) user must have pressed cancel
         RETURN ( aFiles )
      END
      x := At( Chr( 0 ), cFile ) // first null
      cPath := Left( cFile, x )

      cFile := StrTran( cFile, cPath )
      IF ! Empty( cFile ) // user selected more than 1 file
         c := ''
         FOR n := 1 TO Len( cFile )
            IF SubStr( cFile, n, 1 ) == Chr( 0 )
               AAdd( aFiles, StrTran( cPath, Chr( 0 ) ) + '\' + c )
               c := ''
               LOOP
            END
            c += SubStr( cFile, n, 1 )
         NEXT
      ELSE
         aFiles := { StrTran( cPath, Chr( 0 ) ) }
      ENDIF

      RETURN ( aFiles )
   ENDIF

RETURN ( cRet )

*-----------------------------------------------------------------------------*
FUNCTION Putfile( aFilter, cTitle, cIniDir, lNoChangeCurDir, cFile, nIndex, lPromptOverwrite )
*-----------------------------------------------------------------------------*
   LOCAL n, c := '', cDefExt := ""
   LOCAL nFlags := OFN_EXPLORER

   hb_default( @nIndex, 1 )
   hb_default( @lNoChangeCurDir, .F. )
   hb_default( @lPromptOverwrite, .F. )

   IF lNoChangeCurDir
      nFlags += OFN_NOCHANGEDIR
   ENDIF

   IF lPromptOverwrite
      nFlags += OFN_OVERWRITEPROMPT
   ENDIF

   IF aFilter == NIL
      aFilter := {}
   END

   FOR n := 1 TO Len( aFilter )
      c += aFilter[ n ][ 1 ] + Chr( 0 ) + aFilter[ n ][ 2 ] + Chr( 0 )
      c += Chr( 0 )
   NEXT
/*
Wvt_GetSaveFileName( hWnd, cFile, cTitle, aFilter, nFlags, cInitDir, cDefExt, nIndex)

hWnd:     Handle to parent window
cFile:    (optional) Default FileName
cTitle:   Window Title
aFilter:  Array of Files Types i.e. { {'Data Bases','*.dbf'},{'Clipper','*.prg'} }
nFlags:   OFN_* values default to OFN_EXPLORER
cInitDir: Initial directory
cDefExt:  Default Extension i.e. 'DBF'
nIndex:   Index position of types

Returns:  FileName.
*/
   cFile := WVT__GetSaveFileName( NIL, cFile, cTitle, c, nFlags, cIniDir, cDefExt, @nIndex )

RETURN ( cFile )

#endif

*-----------------------------------------------------------------------------*
FUNCTION GetFont( cInitFontName , nInitFontSize , lBold , lItalic , anInitColor , lUnderLine , lStrikeOut , nCharset )
*-----------------------------------------------------------------------------*
   LOCAL RetArray
   LOCAL rgbcolor As Numeric

   IF IsArrayRGB( anInitColor )
      rgbcolor := RGB( anInitColor [1] , anInitColor [2] , anInitColor [3] )
   ENDIF

   RetArray := ChooseFont( hb_defaultValue( cInitFontName, "" ) , hb_defaultValue( nInitFontSize, 0 ) , ;
      hb_defaultValue( lBold, .F. ) , hb_defaultValue( lItalic, .F. ) , rgbcolor , ;
      hb_defaultValue( lUnderLine, .F. ) , hb_defaultValue( lStrikeOut, .F. ) , hb_defaultValue( nCharSet, 0 ) )

   IF Empty( RetArray [1] )
      RetArray [5] := { Nil, Nil, Nil }
   ELSE
      rgbcolor := RetArray [5]
      RetArray [5] := nRGB2Arr( rgbcolor )
   ENDIF

RETURN RetArray

#ifdef __XHARBOUR__

#pragma BEGINDUMP

#include <wvtutils.c>

#pragma ENDDUMP

#endif