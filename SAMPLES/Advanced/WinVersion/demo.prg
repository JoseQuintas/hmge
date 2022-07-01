/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2007-2022 Grigory Filatov <gfilatov@gmail.com>
*/

#include "minigui.ch"

#define NTRIM( n ) hb_ntos( n )

*--------------------------------------------------------*
PROCEDURE MAIN
*--------------------------------------------------------*
   LOCAL cValue := GetInfoString()

   DEFINE WINDOW Form_1 ;
         AT 0, 0 ;
         WIDTH 260 HEIGHT 474 - iif( IsWin9X() .OR. IsServer(), 10, 0 ) ;
         TITLE 'WinVersion Test' ;
         ICON 'DEMO.ICO' ;
         MAIN ;
         NOMAXIMIZE NOSIZE ;
         FONT 'MS Sans Serif' SIZE 8

      @ 0, 0 EDITBOX Edit_1 ;
         WIDTH Form_1.WIDTH - 2 * GetBorderWidth() + 2 ;
         HEIGHT Form_1.HEIGHT - GetTitleHeight() - 2 * GetBorderHeight() + 2 ;
         VALUE cValue ;
         MAXLENGTH 1024 ;
         NOHSCROLL

   END WINDOW

   Form_1.Center()

   Form_1.Activate()

RETURN

*--------------------------------------------------------*
FUNCTION GetInfoString()
*--------------------------------------------------------*
   LOCAL nMajorVersion := GetMajorVersion()
   LOCAL nMinorVersion := GetMinorVersion()
   LOCAL nBuildNumber := GetBuildNumber()
   LOCAL nPlatformId := GetPlatformId()
   LOCAL nServicePack := GetServicePackNT()
   LOCAL cServicePack := GetServicePackString()
   LOCAL cWinVersion := GetWinVersionString()
   LOCAL bWin95 := IsWin95()
   LOCAL bWin98 := IsWin98()
   LOCAL bWinME := IsWinME()
   LOCAL bWin9X := IsWin9X()
   LOCAL bWinNT := IsWinNT()
   LOCAL bWinNT4 := IsWinNT4()
   LOCAL bWin2000 := IsWin2K()
   LOCAL bWin2KorLater := IsWin2KorLater()
   LOCAL bWin2003 := IsWin2003()
   LOCAL bXP := ( IsWinXP() .AND. GetMajorVersion() == 5 )
   LOCAL bXPorLater := IsWinXPorLater()
   LOCAL bXPHome := ( IsWinXPHome() .AND. GetMajorVersion() == 5 )
   LOCAL bXPPro := ( IsWinXPPro() .AND. GetMajorVersion() == 5 )
   LOCAL bXPSP2 := IsWinXPSP2()
   LOCAL bXPSP3 := IsWinXPSP3()
   LOCAL bMediaCenter := ( IsMediaCenter() .AND. GetMajorVersion() == 5 )
   LOCAL bVista := IsWinVista()
   LOCAL bVistaorLater := IsVistaOrLater()
   LOCAL bServer := IsServer()
   LOCAL bWin7 := IsWin7()
   LOCAL bWin8orLater := IsWin8OrLater()
   LOCAL bWin8 := IsWin8()
   LOCAL bWin81 := IsWin81()
   LOCAL bWin10 := IsWin10()
   LOCAL bWin10orLater := IsWin10OrLater()
   LOCAL bWin11 := IsWin11()
   LOCAL cRetString := ""

   cRetString += "major version = " + NTRIM( nMajorVersion ) + CRLF
   cRetString += "minor version = " + NTRIM( nMinorVersion ) + CRLF
   cRetString += "build number = " + NTRIM( nBuildNumber ) + CRLF
   cRetString += "platform id = " + NTRIM( nPlatformId ) + CRLF
   cRetString += "service pack = " + NTRIM( nServicePack ) + CRLF
   cRetString += "service pack string = " + LTrim( cServicePack ) + CRLF
   cRetString += "version string = " + LTrim( cWinVersion ) + CRLF
   cRetString += "Win95 = " + IF( bWin95, "true", "false" ) + CRLF
   cRetString += "Win98 = " + IF( bWin98, "true", "false" ) + CRLF
   cRetString += "WinME = " + IF( bWinME, "true", "false" ) + CRLF
   cRetString += "Win9X = " + IF( bWin9X, "true", "false" ) + CRLF
   cRetString += "WinNT = " + IF( bWinNT, "true", "false" ) + CRLF
   cRetString += "WinNT4 = " + IF( bWinNT4, "true", "false" ) + CRLF
   cRetString += "Win2000 = " + IF( bWin2000, "true", "false" ) + CRLF
   cRetString += "Win2K or later = " + IF( bWin2KorLater, "true", "false" ) + CRLF
   cRetString += "Win2003 = " + IF( bWin2003, "true", "false" ) + CRLF
   cRetString += "WinXP = " + IF( bXP, "true", "false" ) + CRLF
   cRetString += "WinXP or later = " + IF( bXPorLater, "true", "false" ) + CRLF
   cRetString += "WinXP Home = " + IF( bXPHome, "true", "false" ) + CRLF
   cRetString += "WinXP Pro = " + IF( bXPPro, "true", "false" ) + CRLF
   cRetString += "WinXP SP2 = " + IF( bXPSP2, "true", "false" ) + CRLF
   cRetString += "WinXP SP3 = " + IF( bXPSP3, "true", "false" ) + CRLF
   cRetString += "Media Center = " + IF( bMediaCenter, "true", "false" ) + CRLF
   cRetString += "Vista = " + IF( bVista, "true", "false" ) + CRLF
   cRetString += "Vista or later = " + IF( bVistaorLater, "true", "false" ) + CRLF
   cRetString += "Server = " + IF( bServer, "true", "false" ) + CRLF
   cRetString += "Win7 = " + IF( bWin7, "true", "false" ) + CRLF
   cRetString += "Win8 or later = " + IF( bWin8orLater, "true", "false" ) + CRLF
   cRetString += "Win8 = " + IF( bWin8, "true", "false" ) + CRLF
   cRetString += "Win8.1 = " + IF( bWin81, "true", "false" ) + CRLF
   cRetString += "Win10 = " + IF( bWin10, "true", "false" ) + CRLF
   cRetString += "Win10 or later = " + IF( bWin10orLater, "true", "false" ) + CRLF
   cRetString += "Win11 = " + IF( bWin11, "true", "false" )

RETURN cRetString


/////////////////////////////////////////////////////////////////////////////
// NAME                             DESCRIPTION
// ---------------------   ----------------------------------------------
// GetMajorVersion()       Get major version number
// GetMinorVersion()       Get minor version number
// GetBuildNumber()        Get build number (ANDed with 0xFFFF for Win9x)
// GetServicePackNT()      Get service pack number
// GetPlatformId()         Get platform id
// GetServicePackString()  Get service pack string
// GetWinVersionString()   Get windows version as string
// IsMediaCenter()         TRUE = Media Center Edition
// IsWin95()               TRUE = Win95
// IsWin98()               TRUE = Win98
// IsWinME()               TRUE = WinME
// IsWin2K()               TRUE = Win2000
// IsWin2KorLater()        TRUE = Win2000 or later
// IsWin2003()             TRUE = Win2003
// IsWinXP()               TRUE = WinXP
// IsWinXPorLater()        TRUE = WinXP or later
// IsWinXPHome()           TRUE = WinXP Home
// IsWinXPPro()            TRUE = WinXP Pro
// IsWinXPSP2()            TRUE = WinXP SP2
// IsWinXPSP3()            TRUE = WinXP SP3
// IsWinVista()            TRUE = Vista
// IsVistaorLater()        TRUE = Vista or later
// IsWin7()                TRUE = Win7
// IsWin8orLater()         TRUE = Win8 or later
// IsWin8()                TRUE = Win8
// IsWin81()               TRUE = Win8.1
// IsWin10()               TRUE = Win10
// IsWin11()               TRUE = Win11

*--------------------------------------------------------*
FUNCTION GetMajorVersion()
*--------------------------------------------------------*
   LOCAL aVer := GetWinVersionInfo()

RETURN aVer[ 1 ]

*--------------------------------------------------------*
FUNCTION GetMinorVersion()
*--------------------------------------------------------*
   LOCAL aVer := GetWinVersionInfo()

RETURN aVer[ 2 ]

*--------------------------------------------------------*
FUNCTION GetBuildNumber()
*--------------------------------------------------------*
   LOCAL aVer := GetWinVersionInfo()

RETURN aVer[ 3 ]

*--------------------------------------------------------*
FUNCTION GetPlatformId()
*--------------------------------------------------------*
   LOCAL aVer := GetWinVersionInfo()

RETURN aVer[ 4 ]

*--------------------------------------------------------*
FUNCTION GetWinVersionString()
*--------------------------------------------------------*
   LOCAL aVer := WinVersion()

RETURN aVer[ 1 ]

*--------------------------------------------------------*
FUNCTION GetServicePackString()
*--------------------------------------------------------*
   LOCAL aVer := WinVersion()

RETURN aVer[ 2 ]

*--------------------------------------------------------*
FUNCTION GetServicePackNT()
*--------------------------------------------------------*

RETURN iif( IsWin2KorLater(), Val( Right( Trim( GetServicePackString() ), 1 ) ), 0 )

*--------------------------------------------------------*
FUNCTION IsWinXPHome()
*--------------------------------------------------------*
   LOCAL aVer := WinVersion()

RETURN iif( IsWinXP(), "Home" $ aVer[ 4 ], .F. )

*--------------------------------------------------------*
FUNCTION IsWinXPPro()
*--------------------------------------------------------*
   LOCAL aVer := WinVersion()

RETURN iif( IsWinXP(), "Pro" $ aVer[ 4 ], .F. )

*--------------------------------------------------------*
FUNCTION IsWinXPSP2()
*--------------------------------------------------------*

RETURN iif( IsWinXP(), GetServicePackNT() == 2, .F. )

*--------------------------------------------------------*
FUNCTION IsWinXPSP3()
*--------------------------------------------------------*

RETURN iif( IsWinXP(), GetServicePackNT() == 3, .F. )

*--------------------------------------------------------*
FUNCTION IsServer()
*--------------------------------------------------------*

RETURN iif( IsVistaOrLater(), 'Server' $ GetWinVersionString(), .F. )

*--------------------------------------------------------*
FUNCTION IsWin7()
*--------------------------------------------------------*

RETURN iif( IsVistaOrLater(), '7' $ GetWinVersionString(), .F. )

*--------------------------------------------------------*
FUNCTION IsWin8()
*--------------------------------------------------------*

RETURN iif( IsWin8OrLater(), GetMajorVersion() == 6 .AND. GetMinorVersion() == 2, .F. )

*--------------------------------------------------------*
FUNCTION IsWin81()
*--------------------------------------------------------*

RETURN iif( IsWin8OrLater(), GetMajorVersion() == 6 .AND. GetMinorVersion() == 3, .F. )

*--------------------------------------------------------*
FUNCTION IsWin10()
*--------------------------------------------------------*

RETURN ( GetMajorVersion() == 10 .AND. GetBuildNumber() < 22000 )

*--------------------------------------------------------*
FUNCTION IsWin11()
*--------------------------------------------------------*

RETURN iif( GetMajorVersion() == 10, '11' $ GetWinVersionString(), .F. )


#pragma BEGINDUMP

#define SM_MEDIACENTER          87

#include <windows.h>
#include "hbapiitm.h"

static void getwinver(  OSVERSIONINFO * pOSvi )
{
  pOSvi->dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
  GetVersionEx ( pOSvi );
}

HB_FUNC( ISWINNT )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT );
}

HB_FUNC( ISWIN9X )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS );
}

HB_FUNC( ISWIN95 )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS
        && osvi.dwMajorVersion == 4 && osvi.dwMinorVersion == 0 );
}

HB_FUNC( ISWIN98 )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS
        && osvi.dwMajorVersion == 4 && osvi.dwMinorVersion == 10 );
}

HB_FUNC( ISWINME )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS
        && osvi.dwMajorVersion == 4 && osvi.dwMinorVersion == 90 );
}

HB_FUNC( ISWINNT351 )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT
        && osvi.dwMajorVersion == 3 && osvi.dwMinorVersion == 51 );
}

HB_FUNC( ISWINNT4 )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT
        && osvi.dwMajorVersion == 4 && osvi.dwMinorVersion == 0 );
}

HB_FUNC( ISWIN2K )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 0 );
}

HB_FUNC( ISWINXP )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 1 );
}

HB_FUNC( ISWIN2003 )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 2 );
}

HB_FUNC( ISWINVISTA )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 0 );
}

HB_FUNC( ISWIN2KORLATER )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( osvi.dwMajorVersion >= 5 );
}

HB_FUNC( ISWIN8ORLATER )
{
  OSVERSIONINFO osvi;
  getwinver( &osvi );
  hb_retl( (osvi.dwMajorVersion >= 6 && osvi.dwMinorVersion > 1) ||
  osvi.dwMajorVersion == 10 );
}

HB_FUNC( GETWINVERSIONINFO )
{
  OSVERSIONINFO osvi;
  PHB_ITEM pArray = hb_itemArrayNew( 5 );
  getwinver( &osvi );
  hb_itemPutNL( hb_arrayGetItemPtr( pArray, 1 ), osvi.dwMajorVersion );
  hb_itemPutNL( hb_arrayGetItemPtr( pArray, 2 ), osvi.dwMinorVersion );
  if ( osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS )
  {
    osvi.dwBuildNumber = LOWORD( osvi.dwBuildNumber );
  }
  hb_itemPutNL( hb_arrayGetItemPtr( pArray, 3 ), osvi.dwBuildNumber  );
  hb_itemPutNL( hb_arrayGetItemPtr( pArray, 4 ), osvi.dwPlatformId   );
  hb_itemPutC(  hb_arrayGetItemPtr( pArray, 5 ), osvi.szCSDVersion   );
  hb_itemRelease( hb_itemReturn( pArray) );
}

HB_FUNC( ISMEDIACENTER )
{
  if (GetSystemMetrics(SM_MEDIACENTER))
    hb_retl( TRUE );
  else
    hb_retl( FALSE );
}

#pragma ENDDUMP
