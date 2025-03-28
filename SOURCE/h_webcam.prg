/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

WEBCAM Control Source Code
Copyright 2012 Grigory Filatov <gfilatov@gmail.com>

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

#include "minigui.ch"

#ifdef _USERINIT_
#include "i_winuser.ch"

*------------------------------------------------------------------------------*
INIT PROCEDURE _InitWebCam
*------------------------------------------------------------------------------*

   InstallMethodHandler ( 'Start', '_StartWebCam' )
   InstallMethodHandler ( 'Release', '_ReleaseWebCam' )

RETURN

*------------------------------------------------------------------------------*
FUNCTION _DefineWebCam ( ControlName, ParentForm, x, y, w, h, lStart, nRate, tooltip, HelpId )
*------------------------------------------------------------------------------*
   LOCAL ControlHandle
   LOCAL cParentForm
   LOCAL mVar

   hb_default( @w, 320 )
   hb_default( @h, 240 )
   hb_default( @nRate, 30 )

   IF _HMG_BeginWindowActive
      ParentForm := _HMG_ActiveFormName
   ENDIF

   IF _HMG_FrameLevel > 0
      x := x + _HMG_ActiveFrameCol[ _HMG_FrameLevel ]
      y := y + _HMG_ActiveFrameRow[ _HMG_FrameLevel ]
      ParentForm := _HMG_ActiveFrameParentFormName[ _HMG_FrameLevel ]
   ENDIF

   IF ! _IsWindowDefined ( ParentForm )
      MsgMiniGuiError( "Window: " + ParentForm + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentForm )
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentForm + " Already defined." )
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

#ifdef _NAMES_LIST_
   _SetNameList( mVar, Len ( _HMG_aControlNames ) + 1 )
#else
   PUBLIC &mVar. := Len ( _HMG_aControlNames ) + 1
#endif

   cParentForm := ParentForm

   ParentForm := GetFormHandle ( ParentForm )

   ControlHandle := cap_CreateCaptureWindow ( "WebCam", hb_bitOr( WS_CHILD, WS_VISIBLE ), x, y, w, h, ParentForm, 0 )

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap, Controlhandle )
   ENDIF

   IF tooltip != NIL
      SetToolTip ( ControlHandle, tooltip, GetFormToolTipHandle ( cParentForm ) )
   ENDIF

   AAdd ( _HMG_aControlType, "WEBCAM" )
   AAdd ( _HMG_aControlNames, ControlName )
   AAdd ( _HMG_aControlHandles, ControlHandle )
   AAdd ( _HMG_aControlParentHandles, ParentForm )
   AAdd ( _HMG_aControlIds, 0 )
   AAdd ( _HMG_aControlProcedures, "" )
   AAdd ( _HMG_aControlPageMap, {} )
   AAdd ( _HMG_aControlValue, nRate )
   AAdd ( _HMG_aControlInputMask, "" )
   AAdd ( _HMG_aControllostFocusProcedure, "" )
   AAdd ( _HMG_aControlGotFocusProcedure, "" )
   AAdd ( _HMG_aControlChangeProcedure, "" )
   AAdd ( _HMG_aControlDeleted, .F. )
   AAdd ( _HMG_aControlBkColor, {} )
   AAdd ( _HMG_aControlFontColor, {} )
   AAdd ( _HMG_aControlDblClick, "" )
   AAdd ( _HMG_aControlHeadClick, {} )
   AAdd ( _HMG_aControlRow, y )
   AAdd ( _HMG_aControlCol, x )
   AAdd ( _HMG_aControlWidth, w )
   AAdd ( _HMG_aControlHeight, h )
   AAdd ( _HMG_aControlSpacing, 0 )
   AAdd ( _HMG_aControlContainerRow, iif ( _HMG_FrameLevel > 0, _HMG_ActiveFrameRow[ _HMG_FrameLevel ], -1 ) )
   AAdd ( _HMG_aControlContainerCol, iif ( _HMG_FrameLevel > 0, _HMG_ActiveFrameCol[ _HMG_FrameLevel ], -1 ) )
   AAdd ( _HMG_aControlPicture, "" )
   AAdd ( _HMG_aControlContainerHandle, 0 )
   AAdd ( _HMG_aControlFontName, '' )
   AAdd ( _HMG_aControlFontSize, 0 )
   AAdd ( _HMG_aControlFontAttributes, { FALSE, FALSE, FALSE, FALSE } )
   AAdd ( _HMG_aControlToolTip, tooltip )
   AAdd ( _HMG_aControlRangeMin, 0 )
   AAdd ( _HMG_aControlRangeMax, 0 )
   AAdd ( _HMG_aControlCaption, '' )
   AAdd ( _HMG_aControlVisible, .F. )
   AAdd ( _HMG_aControlHelpId, HelpId )
   AAdd ( _HMG_aControlFontHandle, 0 )
   AAdd ( _HMG_aControlBrushHandle, 0 )
   AAdd ( _HMG_aControlEnabled, .T. )
   AAdd ( _HMG_aControlMiscData1, 0 )
   AAdd ( _HMG_aControlMiscData2, '' )

   IF lStart
      IF ! _StartWebCam ( cParentForm, ControlName )
         MsgAlert( "Webcam service is unavailable!", "Alert" )
      ENDIF
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION _StartWebCam ( cWindow, cControl )
*------------------------------------------------------------------------------*
   LOCAL hWnd
   LOCAL w
   LOCAL h
   LOCAL nTry := 1
   LOCAL lSuccess

   hWnd := GetControlHandle ( cControl, cWindow )

   REPEAT
      lSuccess := cap_DriverConnect ( hWnd, 0 )
      DO EVENTS
   UNTIL ( lSuccess == .F. .AND. nTry++ < 3 )

   IF lSuccess
      w := _GetControlWidth ( cControl, cWindow )
      h := _GetControlHeight ( cControl, cWindow )

      cap_SetVideoFormat ( hWnd, Min( w, 320 ), Min( h, 240 ) )

      lSuccess := ( cap_PreviewScale( hWnd, .T. ) .AND. ;
         cap_PreviewRate( hWnd, GetControlValue ( cControl, cWindow ) ) .AND. ;
         cap_Preview( hWnd, .T. ) )
   ELSE
      // error connecting to video source
      DestroyWindow ( hWnd )
   ENDIF

   _HMG_aControlVisible[ GetControlIndex ( cControl, cWindow ) ] := lSuccess

RETURN lSuccess

*------------------------------------------------------------------------------*
PROCEDURE _ReleaseWebCam ( cWindow, cControl )
*------------------------------------------------------------------------------*
   LOCAL hWnd

   IF _IsControlDefined ( cControl, cWindow ) .AND. GetControlType ( cControl, cWindow ) == 'WEBCAM'

      hWnd := GetControlHandle ( cControl, cWindow )

      IF ! Empty ( hWnd )

         cap_DriverDisconnect ( hWnd )

         DestroyWindow ( hWnd )

         _EraseControl ( GetControlIndex ( cControl, cWindow ), GetFormIndex ( cWindow ) )

      ENDIF

      _HMG_UserComponentProcess := .T.

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN

/*
 * C-level
 */
#pragma BEGINDUMP

#include <mgdefs.h>
#include <vfw.h>

#if defined( __BORLANDC__ )
#pragma warn -use /* unused var */
#pragma warn -eff /* no effect */
#endif

#ifdef UNICODE
LPWSTR AnsiToWide( LPCSTR );
#endif

HB_FUNC( CAP_CREATECAPTUREWINDOW )
{
#ifndef UNICODE
   LPCSTR lpszWindowName = hb_parc( 1 );
#else
   LPWSTR lpszWindowName = AnsiToWide( ( char * ) hb_parc( 1 ) );
#endif

   hmg_ret_raw_HWND
      (
         capCreateCaptureWindow
            (
         lpszWindowName,
         hmg_par_DWORD( 2 ),
         hb_parni( 3 ),
         hb_parni( 4 ),
         hb_parni( 5 ),
         hb_parni( 6 ),
         hmg_par_raw_HWND( 7 ),
         hb_parni( 8 )
            )
      );
}

HB_FUNC( CAP_DRIVERCONNECT )
{
   hb_retl( capDriverConnect( hmg_par_raw_HWND( 1 ), hb_parni( 2 ) ) );
}

HB_FUNC( CAP_DRIVERDISCONNECT )
{
   hb_retl( capDriverDisconnect( hmg_par_raw_HWND( 1 ) ) );
}

HB_FUNC( CAP_SETVIDEOFORMAT )
{
   BITMAPINFO binf;
   HWND hCapWnd = hmg_par_raw_HWND( 1 );

   capGetVideoFormat( hCapWnd, &binf, sizeof( BITMAPINFO ) );

   binf.bmiHeader.biWidth        = hb_parni( 2 );
   binf.bmiHeader.biHeight       = hb_parni( 3 );
   binf.bmiHeader.biPlanes       = 1;
   binf.bmiHeader.biBitCount     = 24;
   binf.bmiHeader.biCompression  = BI_RGB;
   binf.bmiHeader.biSizeImage    = 0;
   binf.bmiHeader.biClrUsed      = 0;
   binf.bmiHeader.biClrImportant = 0;

   hb_retl( capSetVideoFormat( hCapWnd, &binf, sizeof( BITMAPINFO ) ) );
}

HB_FUNC( CAP_PREVIEWRATE )
{
   hb_retl( capPreviewRate( hmg_par_raw_HWND( 1 ), hmg_par_WORD( 2 ) ) );
}

HB_FUNC( CAP_PREVIEWSCALE )
{
   hb_retl( capPreviewScale( hmg_par_raw_HWND( 1 ), hb_parl( 2 ) ) );
}

HB_FUNC( CAP_PREVIEW )
{
   hb_retl( capPreview( hmg_par_raw_HWND( 1 ), hb_parl( 2 ) ) );
}

HB_FUNC( CAP_EDITCOPY )
{
   hb_retl( capEditCopy( hmg_par_raw_HWND( 1 ) ) );
}

#pragma ENDDUMP

#endif
