/*
 * Author: P.Chornyj <myorg63@mail.ru>
 *
 * A Quick & Easy guide to Microsoft Windows Icon Size
 * https://www.creativefreedom.co.uk/icon-designers-blog/windows-7-icon-sizes/
 */

ANNOUNCE RDDSYS

#include "minigui.ch"

#define LOAD_LIBRARY_AS_DATAFILE   0x00000002
///////////////////////////////////////////////////////////////////////////////
procedure main()

   local hLib
   local cIcon := 'ICONVISTA', hIconFromDll, hIcon
   local aInfo, w, h

   hLib := LoadLibraryEx( 'myicons.dll', 0, LOAD_LIBRARY_AS_DATAFILE )

   if ! Empty( hLib )
      if IsVistaOrLater()
         hIconFromDll := LoadIconByName( cIcon, 256, 256, hLib )
      elseif IsWinXPorLater()
         hIconFromDll := LoadIconByName( cIcon, 128, 128, hLib )
      endif

      if ! Empty( hIconFromDll )
         hIcon := CopyIcon( hIconFromDll )
         DestroyIcon( hIconFromDll )
      endif

      FreeLibrary( hLib )
   endif

   if Empty( hIcon )
      quit
   endif

   aInfo := GetIconSize( hIcon )
   w := aInfo[ 1 ]
   h := aInfo[ 2 ]

   define window Form_Main ;
      clientarea w, h + GetMenuBarHeight() ;
      title 'Icons Demo (use a Dll)' ;
      main ;
      nomaximize nosize ;
      on release ;
      ( ;
         DestroyIcon( hIcon ) ;
      )

      define main menu
         define popup "&File" 
            menuitem "&Save multipages icon" action MsgInfo( SaveIcon( "myicon.ico", cIcon, { 16, 24, 32, 128 } ), "Result" )
            separator
            menuitem "E&xit" action ThisWindow.Release
         end popup
      end menu
   end window

   draw icon in window Form_Main at 0, 0 hicon hIcon width w height h

   on key Escape of Form_Main action ThisWindow.Release

   Form_Main.Center()
   Form_Main.Activate()

return

///////////////////////////////////////////////////////////////////////////////
Function SaveIcon( cIconName, cIcon, aSizes )
   local hLib
   local aIcons := {}, i

   hLib := LoadLibraryEx( 'myicons.dll', 0, LOAD_LIBRARY_AS_DATAFILE )

   For i = 1 To Len( aSizes )
         AAdd( aIcons, LoadIconByName( cIcon, aSizes[i], aSizes[i], hLib ) )
   Next

   FreeLibrary( hLib )

Return C_SaveHIconToFile( cIconName, aIcons )
