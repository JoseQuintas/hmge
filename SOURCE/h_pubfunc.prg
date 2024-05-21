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

#include "minigui.ch"

// ============================================================================

FUNCTION HideWindow ( hWnd )
RETURN ;
      ShowWindow( hWnd, SW_HIDE )

FUNCTION _Maximize ( hWnd )
RETURN ;
      ShowWindow( hWnd, SW_MAXIMIZE )

FUNCTION _MaximizeWindow ( FormName )
RETURN ;
      _Maximize( GetFormHandle( FormName ) )

FUNCTION _Minimize ( hWnd )
RETURN ;
      ShowWindow( hWnd, SW_MINIMIZE )

FUNCTION _MinimizeWindow ( FormName )
RETURN ;
      _Minimize( GetFormHandle( FormName ) )

FUNCTION _Restore ( hWnd )
RETURN ;
      ShowWindow( hWnd, SW_RESTORE )

FUNCTION _RestoreWindow ( FormName )
RETURN ;
      _Restore( GetFormHandle( FormName ) )

// ============================================================================

FUNCTION GetSpecialFolder ( nCSIDL )
RETURN ;
      C_GetSpecialFolder( nCSIDL )

FUNCTION GetWindowsFolder ()
RETURN ;
      GetWindowsDir()

FUNCTION GetSystemFolder ()
RETURN ;
      GetSystemDir()

FUNCTION GetTempFolder ()
RETURN ;
      cFilePath( GetTempDir() )

FUNCTION GetWindowsTempFolder ()
RETURN ;
      GetWindowsDir() + "\Temp"

FUNCTION GetMyDocumentsFolder ()
RETURN ;
      GetSpecialFolder( CSIDL_PERSONAL )

FUNCTION GetDesktopFolder ()
RETURN ;
      GetSpecialFolder( CSIDL_DESKTOPDIRECTORY )

FUNCTION GetApplicationDataFolder ()
RETURN ;
      GetSpecialFolder( CSIDL_APPDATA )

FUNCTION GetAppLocalDataFolder ()
RETURN ;
      GetSpecialFolder( CSIDL_LOCAL_APPDATA )

FUNCTION GetUserProfileFolder ()
RETURN ;
      GetSpecialFolder( CSIDL_PROFILE )

FUNCTION GetUserTempFolder ()
RETURN ;
      iif( IsVistaOrLater(), GetAppLocalDataFolder() + "\Temp", cFilePath( GetTempDir() ) )

FUNCTION GetProgramFilesFolder ()
RETURN ;
      GetSpecialFolder( CSIDL_PROGRAM_FILES )

FUNCTION GetStartUpFolder ()
RETURN ;
      cFilePath( GetExeFilename() )

FUNCTION GetProgramFilename ()
RETURN ;
      GetExeFilename()

#if defined( __XHARBOUR__ )
FUNCTION GetModuleFilename ( x )
HB_SYMBOL_UNUSED( x )
#else
FUNCTION GetModuleFilename ( ... )
#endif
RETURN ;
      GetExeFilename()

// ============================================================================

FUNCTION CShowControl ( hWnd )
RETURN ;
      ShowWindow ( hWnd )

FUNCTION IsTabStop ( hWnd )
RETURN ;
      IsWindowHasStyle ( hWnd, 0x00010000 )

FUNCTION SetTabStop ( hWnd, ltab )
RETURN ;
      SetWindowStyle ( hWnd, 0x00010000, ltab )

FUNCTION IsWindowSized ( hWnd )
RETURN ;
      IsWindowHasStyle ( hWnd, 0x00040000 )

FUNCTION SetWindowBackground ( hWnd, hBrush )
RETURN ;
      SetWindowBrush ( hWnd, hBrush )

// ============================================================================

FUNCTION _GetKeyState( VKey )
RETURN ;
      CheckBit( GetKeyState( VKey ), 32768 )

FUNCTION GetEscapeState ()
RETURN ;
      GetKeyState( VK_ESCAPE )

FUNCTION GetAltState ()
RETURN ;
      GetKeyState( VK_MENU )

FUNCTION IsAltActive()
RETURN ;
      CheckBit( GetAsyncKeyState( VK_MENU ), 32768 )

FUNCTION IsInsertActive ()
RETURN ;
      ( GetKeyState( VK_INSERT ) > 0 )

FUNCTION IsCapsLockActive ()
RETURN ;
      ( GetKeyState( VK_CAPITAL ) > 0 )

FUNCTION IsNumLockActive ()
RETURN ;
      ( GetKeyState( VK_NUMLOCK ) > 0 )

FUNCTION IsScrollLockActive ()
RETURN ;
      ( GetKeyState( VK_SCROLL ) > 0 )

// ============================================================================

FUNCTION IsWinNT () ;; RETURN os_IsWinNT()

FUNCTION IsWinXPorLater () ;; RETURN os_IsWinXP_Or_Later()

FUNCTION IsVista () ;; RETURN os_IsWinVista()

FUNCTION IsVistaOrLater () ;; RETURN os_IsWinVista_Or_Later()

FUNCTION IsSeven () ;; RETURN os_IsWin7()

#if ! defined( __XHARBOUR__ )
FUNCTION IsWin64 () ;; RETURN hb_osIs64bit()
#endif

FUNCTION hb_osIsWin11() ;; RETURN '11' $ WinVersion() [ 1 ]

FUNCTION IsWin10OrLater () ;; RETURN ( hb_osIsWin10() .OR. hb_osIsWin11() )

// ============================================================================

FUNCTION PlayBeep ()
RETURN ;
      MessageBeep( 0xFFFFFFFF )

FUNCTION PlayAsterisk ()
RETURN ;
      MessageBeep( 64 )

FUNCTION PlayExclamation ()
RETURN ;
      MessageBeep( 48 )

FUNCTION PlayHand ()
RETURN ;
      MessageBeep( 16 )

FUNCTION PlayQuestion ()
RETURN ;
      MessageBeep( 32 )

FUNCTION PlayOk ()
RETURN ;
      MessageBeep( 0 )

// ============================================================================

FUNCTION PlayWaveFromResource( wave )
RETURN ;
      C_PlayWave( wave, .T., .F., .F., .F., .F. )

FUNCTION _PlayPlayer ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 1 )

FUNCTION _StopPlayer ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 2 )

FUNCTION _PausePlayer ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 3 )

FUNCTION _ClosePlayer ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 4 )

FUNCTION _DestroyPlayer ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 5 )

FUNCTION _EjectPlayer ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 6 )

FUNCTION _SetPlayerPositionEnd ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 7 )

FUNCTION _SetPlayerPositionHome ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 8 )

FUNCTION _OpenPlayer ( ControlName, ParentFormName, file )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 9, file )

FUNCTION _OpenPlayerDialog ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 10 )

FUNCTION _PlayPlayerReverse ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 11 )

FUNCTION _ResumePlayer ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 12 )

FUNCTION _SetPlayerRepeatOn ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 13, .T. )

FUNCTION _SetPlayerRepeatOff ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 13, .F. )

FUNCTION _SetPlayerSpeed ( ControlName, ParentFormName, speed )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 14, speed )

FUNCTION _SetPlayerVolume ( ControlName, ParentFormName, volume )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 15, volume )

FUNCTION _SetPlayerZoom ( ControlName, ParentFormName, zoom )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 16, zoom )

FUNCTION _GetPlayerLength ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 17 )

FUNCTION _GetPlayerPosition ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 18 )

FUNCTION _GetPlayerVolume ( ControlName, ParentFormName )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 19 )

FUNCTION _SetPlayerPosition ( ControlName, ParentFormName, pos )
RETURN ;
      mcifunc ( GetControlHandle( ControlName, ParentFormName ), 20, pos )

// ============================================================================

FUNCTION _OpenAnimateBox ( ControlName, ParentFormName, FileName )
RETURN ;
      openanimate ( GetControlHandle( ControlName, ParentFormName ), FileName )

FUNCTION _PlayAnimateBox ( ControlName, ParentFormName )
RETURN ;
      playanimate ( GetControlHandle( ControlName, ParentFormName ) )

FUNCTION _SeekAnimateBox ( ControlName, ParentFormName, Frame )
RETURN ;
      seekanimate ( GetControlHandle( ControlName, ParentFormName ), Frame )

FUNCTION _StopAnimateBox ( ControlName, ParentFormName )
RETURN ;
      stopanimate ( GetControlHandle( ControlName, ParentFormName ) )

FUNCTION _CloseAnimateBox ( ControlName, ParentFormName )
RETURN ;
      closeanimate ( GetControlHandle( ControlName, ParentFormName ) )

FUNCTION _DestroyAnimateBox ( ControlName, ParentFormName )
RETURN ;
      destroywindow ( GetControlHandle( ControlName, ParentFormName ) )

// ============================================================================

FUNCTION _GetBrowseAllowAppend ( ControlName, ParentFormName )
RETURN ;
      _SetGetBrowseProperty ( ControlName, ParentFormName, 2 )

FUNCTION _GetBrowseAllowEdit ( ControlName, ParentFormName )
RETURN ;
      _SetGetBrowseProperty ( ControlName, ParentFormName, 6 )

FUNCTION _GetBrowseAllowDelete ( ControlName, ParentFormName )
RETURN ;
      _SetGetBrowseProperty ( ControlName, ParentFormName, 12 )

FUNCTION _GetBrowseInputItems ( ControlName, ParentFormName )
RETURN ;
      _SetGetBrowseProperty ( ControlName, ParentFormName, 13 )

FUNCTION _GetBrowseDisplayItems ( ControlName, ParentFormName )
RETURN ;
      _SetGetBrowseProperty ( ControlName, ParentFormName, 14 )

FUNCTION _SetBrowseAllowAppend ( ControlName, ParentFormName, Value )
RETURN ;
      _SetGetBrowseProperty ( ControlName, ParentFormName, 2, Value )

FUNCTION _SetBrowseAllowEdit ( ControlName, ParentFormName, Value )
RETURN ;
      _SetGetBrowseProperty ( ControlName, ParentFormName, 6, Value )

FUNCTION _SetBrowseAllowDelete ( ControlName, ParentFormName, Value )
RETURN ;
      _SetGetBrowseProperty ( ControlName, ParentFormName, 12, Value )

FUNCTION _SetBrowseInputItems ( ControlName, ParentFormName, Value )
RETURN ;
      _SetGetBrowseProperty ( ControlName, ParentFormName, 13, Value )

FUNCTION _SetBrowseDisplayItems ( ControlName, ParentFormName, Value )
RETURN ;
      _SetGetBrowseProperty ( ControlName, ParentFormName, 14, Value )

// ============================================================================

FUNCTION GetHotKeyName ( ControlName, FormName )
RETURN ;
      _GetHotKeyName ( ControlName, FormName )

FUNCTION GetHotKeyValue ( ControlName, FormName )
RETURN ;
      _GetHotKeyValue ( ControlName, FormName )

FUNCTION _GetHotKeyValue( ControlName, FormName )
RETURN ;
      C_GetHotKeyValue( GetControlHandle( ControlName, FormName ) )

// ============================================================================

FUNCTION IsErrorLogActive ()
RETURN ;
      _HMG_CreateErrorLog

FUNCTION _GetErrorlogFile ()
RETURN ;
      _HMG_ErrorLogFile

// ============================================================================

FUNCTION _GetNotifyIconName ( FormName )
RETURN ;
      _HMG_aFormNotifyIconName[ GetFormIndex( FormName ) ]

FUNCTION _GetNotifyIconTooltip ( FormName )
RETURN ;
      _HMG_aFormNotifyIconTooltip[ GetFormIndex( FormName ) ]

FUNCTION _GetRadioGroupReadOnly ( ControlName, FormName )
RETURN ;
      GetControlPageMap ( ControlName, FormName )

FUNCTION _GetAddress ( ControlName, FormName )
RETURN ;
      _HMG_aControlValue[ GetControlIndex ( ControlName, FormName ) ]

FUNCTION RC_CURSOR ( cCursor )
RETURN ;
      SetResCursor ( LoadCursor( GetInstance(), cCursor ) )

FUNCTION GetCursorRow ()
RETURN ;
      GetCursorPos() [ 1 ]

FUNCTION GetCursorCol ()
RETURN ;
      GetCursorPos() [ 2 ]

FUNCTION LB_String2Array( cData, Sep )
RETURN ;
      hb_ATokens( cData, iif( HB_ISSTRING( Sep ), Sep, Chr( 9 ) ) )

// ============================================================================

FUNCTION _DestroyImageList ( ControlName, ParentFormName )
   ImageList_Destroy ( GetControlHandle( ControlName, ParentFormName ) )
   _ReleaseControl ( ControlName, ParentFormName )

RETURN NIL

FUNCTION IL_DESTROY ( h )
RETURN ;
      ImageList_Destroy ( h )

FUNCTION _DragEnterImage ( ix, iy )
RETURN ;
      IL_DragEnter ( _HMG_ActiveDragImageHandle, ix, iy )

FUNCTION _MoveImage ( ix, iy )
RETURN ;
      IL_DragMove ( ix, iy )

FUNCTION _EndDragImage ()
RETURN ;
      IL_EndDrag ( _HMG_ActiveDragImageHandle )

FUNCTION _GetImageCount ( ControlName, ParentFormName )
RETURN ;
      IL_GetImageCount ( GetControlHandle( ControlName, ParentFormName ) )

FUNCTION _RemoveImageFromImageList ( ControlName, ParentFormName, ImageIndex )
RETURN ;
      IL_Remove( GetControlHandle( ControlName, ParentFormName ), ImageIndex )

FUNCTION _DrawImageFromImageList ( ControlName, ParentFormName, ImageIndex, cx, cy )
RETURN ;
      IL_Draw( GetFormHandle ( ParentFormName ), GetControlHandle( ControlName, ParentFormName ), ImageIndex, cx, cy )

// ============================================================================

FUNCTION _AddChildToPager ( ControlName, ParentFormName )
RETURN ;
      AddToPager ( _HMG_ActivePagerForm, GetControlHandle( ControlName, ParentFormName ) )

FUNCTION _Pager_ForwardMouse ( ControlName, ParentFormName, lEnable )
RETURN ;
      PagerForwardMouse ( GetControlHandle( ControlName, ParentFormName ), IFLOGICAL( lEnable, lEnable, .F. ) )

FUNCTION _Pager_GetButtonSize ( ControlName, ParentFormName )
RETURN ;
      PagerGetButtonSize ( GetControlHandle( ControlName, ParentFormName ) )

FUNCTION _Pager_SetButtonSize ( ControlName, ParentFormName, nSize )
RETURN ;
      PagerSetButtonSize ( GetControlHandle( ControlName, ParentFormName ), nSize )

FUNCTION _Pager_GetBorder ( ControlName, ParentFormName )
RETURN ;
      PagerGetBorder ( GetControlHandle( ControlName, ParentFormName ) )

FUNCTION _Pager_SetBorder ( ControlName, ParentFormName, nSize )
RETURN ;
      PagerSetBorder ( GetControlHandle( ControlName, ParentFormName ), nSize )

FUNCTION _Pager_GetPos ( ControlName, ParentFormName )
RETURN ;
      PagerGetPos ( GetControlHandle( ControlName, ParentFormName ) )

FUNCTION _Pager_SetPos ( ControlName, ParentFormName, nPos )
RETURN ;
      PagerSetPos ( GetControlHandle( ControlName, ParentFormName ), nPos )

// ============================================================================

FUNCTION _SetControlCol ( ControlName, ParentForm, Value )
RETURN ;
      _SetControlSizePos ( ControlName, ParentForm, _GetControlRow ( ControlName, ParentForm ), VALUE, _GetControlWidth ( ControlName, ParentForm ), _GetControlHeight ( ControlName, ParentForm ) )

FUNCTION _SetControlRow ( ControlName, ParentForm, Value )
RETURN ;
      _SetControlSizePos ( ControlName, ParentForm, VALUE, _GetControlCol ( ControlName, ParentForm ), _GetControlWidth ( ControlName, ParentForm ), _GetControlHeight ( ControlName, ParentForm ) )

FUNCTION _SetControlWidth ( ControlName, ParentForm, Value )
RETURN ;
      _SetControlSizePos ( ControlName, ParentForm, _GetControlRow ( ControlName, ParentForm ), _GetControlCol ( ControlName, ParentForm ), VALUE, _GetControlHeight ( ControlName, ParentForm ) )

FUNCTION _SetControlHeight ( ControlName, ParentForm, Value )
RETURN ;
      _SetControlSizePos ( ControlName, ParentForm, _GetControlRow ( ControlName, ParentForm ), _GetControlCol ( ControlName, ParentForm ), _GetControlWidth ( ControlName, ParentForm ), Value )

// ============================================================================

FUNCTION GetDesktopWidth ()
RETURN ;
      GetSystemMetrics( SM_CXSCREEN )

FUNCTION GetDesktopHeight ()
RETURN ;
      GetSystemMetrics( SM_CYSCREEN )

FUNCTION GetVScrollBarWidth ()
RETURN ;
      GetSystemMetrics( SM_CXVSCROLL )

FUNCTION GetHScrollBarHeight ()
RETURN ;
      GetSystemMetrics( SM_CYHSCROLL )

FUNCTION GetTitleHeight ()
RETURN ;
      GetSystemMetrics( SM_CYCAPTION )

FUNCTION GetBorderHeight ()
RETURN ;
      GetSystemMetrics( SM_CYSIZEFRAME )

FUNCTION GetBorderWidth ()
RETURN ;
      GetSystemMetrics( SM_CXSIZEFRAME )

FUNCTION Get3DEdgeHeight ()
RETURN ;
      GetSystemMetrics( SM_CYEDGE )

FUNCTION Get3DEdgeWidth ()
RETURN ;
      GetSystemMetrics( SM_CXEDGE )

FUNCTION GetMenuBarHeight ()
RETURN ;
      GetSystemMetrics( SM_CYMENU )

// ============================================================================

FUNCTION GetWindowBorderSize () ; ; RETURN GetNonClient() [ 1 ]

FUNCTION GetScrollBarSize () ;; RETURN GetNonClient() [ 3 ]

FUNCTION GetTitleBarWidth () ;; RETURN GetNonClient() [ 4 ]

FUNCTION GetTitleBarHeight () ;; RETURN GetNonClient() [ 5 ]

FUNCTION GetMenuBarSize () ;; RETURN GetNonClient() [ 7 ]

// ============================================================================

FUNCTION SendMessageWideString( h, n, wp, lp )
RETURN ;
      SendMessageStringW( h, n, wp, lp )

FUNCTION ProcessMessages() ;; RETURN DoEvents()

FUNCTION And( x1, x2 ) ;; RETURN hb_bitAnd( x1, x2 )
#if defined( __XHARBOUR__ )
FUNCTION nOr( p1, p2, p3, p4, p5, p6, p7 ) ;; RETURN hb_bitOr( p1, p2, p3, p4, p5, p6, p7 )
#else
FUNCTION nOr( ... ) ;; RETURN hb_bitOr( ... )
#endif

FUNCTION Random( nMax ) ;; RETURN hb_RandomInt( IFNUMERIC( nMax, nMax, 65535 ) )

FUNCTION _dummy() ;; RETURN iif( .T.,, )

FUNCTION GetFontWidth( FontName, nLen )
RETURN ;
      GetFontParam( GetFontHandle( FontName ) )[ 8 ] * nLen

FUNCTION GetFontHeight( FontName )
RETURN ;
      GetFontParam( GetFontHandle( FontName ) )[ 9 ]

FUNCTION GetFontNameByHandle( hFont )
RETURN ;
      GetFontParam( hFont )[ 10 ]

FUNCTION HMG_RGB2n( p1, p2, p3 )
RETURN IFNUMERIC( p1, RGB( p1, p2, p3 ), IFARRAY( p1, RGB( p1[ 1 ], p1[ 2 ], p1[ 3 ] ), p1 ) )

FUNCTION HMG_n2RGB( x ) ;; RETURN { GetRed( x ), GetGreen( x ), GetBlue( x ) }

FUNCTION _DelGlobal( cVarName ) ;; RETURN _SetGetGlobal( cVarName, , .T. )

#if ! defined( __XHARBOUR__ )
FUNCTION _SetNameList( x, v ) ;; RETURN _SetGetNamesList( x, v )
FUNCTION _GetNameList( x ) ;; RETURN _SetGetNamesList( x )
FUNCTION _DelNameList( x ) ;; RETURN _SetGetNamesList( x, , .T. )

FUNCTION HMG_TimeMS( dTS1, dTS2 ) ;; RETURN LTrim( hb_TSToStr( ( hb_StrToTS( "" ) + ( hb_defaultValue( dTS2, hb_DateTime() ) - dTS1 ) ), .T. ) )
#endif

FUNCTION HMG_SysWait( nSeconds ) ;; RETURN hb_idleSleep( hb_defaultValue( nSeconds, 0.105 ) )

FUNCTION oHmgData( lUpper ) ;; RETURN THmgData():New( hb_defaultValue( lUpper, .T. ) )
