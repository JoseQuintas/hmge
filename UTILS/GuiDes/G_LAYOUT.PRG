/*
 * GuiDes source code:
 *
 * Copyright 2002 Carlos Andr‚s <carlos.andres@navegalia.com>
 * www - http://www.geocities.com/harbour_links/guides
 *
 * GuiDes is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * GuiDes is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 */

#include "GUIDES.CH"
#include "minigui.ch"
#include "hbclass.ch"

DECLARE WINDOW OIWin
DECLARE WINDOW PropInspector
DECLARE WINDOW WinSelec

CREATE CLASS gLayout

   DATA IniFile  INIT ( GuiDesDir + "\GUIDES.INI" )

   DATA OSRow   INIT 205
   DATA OSCol       INIT 0
   DATA OSWidth       INIT 230
   DATA OSHeight        INIT 230

   DATA WSRow   INIT 450
   DATA WSCol       INIT 0
   DATA WSWidth       INIT 230
   DATA WSHeight        INIT 180

   DATA PIRow   INIT 450
   DATA PICol       INIT 0
   DATA PIWidth       INIT 230
   DATA PIHeight        INIT 180

   DATA RecentWindows   INIT {}

   METHOD New()  INLINE Self
   METHOD LoadFromIni()
   METHOD SaveToIni()
   METHOD SetWinsProps()
   METHOD AddRecentWindow( cFileName )
   METHOD ChooseRecent()

ENDCLASS


METHOD LoadFromIni() CLASS gLayout

   LOCAL nCount, nWins := 0
   LOCAL cRecentFileName
   LOCAL cEntry

   IF !File( ::IniFile )
      MsgBox( "GUIDES.INI file wasn't found." + CR_LF + "Your options can't be loaded." )
   ELSE

      BEGIN INI FILE ::IniFile

      GET ::OSRow SECTION "OSelector" ENTRY "Row"
      GET ::OSCol SECTION "OSelector" ENTRY "Col"
      GET ::OSWidth SECTION "OSelector" ENTRY "Width"
      GET ::OSHeight SECTION "OSelector" ENTRY "Height"

      GET ::WSRow SECTION "WinSelec" ENTRY "Row"
      GET ::WSCol SECTION "WinSelec" ENTRY "Col"
      GET ::WSWidth SECTION "WinSelec" ENTRY "Width"
      GET ::WSHeight SECTION "WinSelec" ENTRY "Height"

      GET ::PIRow SECTION "PInspector" ENTRY "Row"
      GET ::PiCol SECTION "PInspector" ENTRY "Col"
      GET ::PIWidth SECTION "PInspector" ENTRY "Width"
      GET ::PIHeight SECTION "PInspector" ENTRY "Height"

      GET nWins SECTION "Recent" ENTRY "Windows" DEFAULT 0
      FOR nCount := 1 TO nWins
         cRecentFileName := ""
         cEntry := "Win_" + AllTrim( Str( nCount ) )
         GET cRecentFileName SECTION "Recent" ENTRY cEntry
         ::AddRecentWindow( cRecentFileName )
      NEXT

      END INI

   ENDIF

RETURN NIL


METHOD SaveToIni() CLASS gLayout

   LOCAL nCount
   LOCAL cEntry

   BEGIN INI FILE ::IniFile

   SET SECTION "OSelector" ENTRY "Row" TO GetProperty( "OIWin", "Row" )
   SET SECTION "OSelector" ENTRY "Col" TO GetProperty( "OIWin", "Col" )
   SET SECTION "OSelector" ENTRY "Width" TO GetProperty( "OIWin", "Width" )
   SET SECTION "OSelector" ENTRY "Height" TO GetProperty( "OIWin", "Height" )

   SET SECTION "WinSelec" ENTRY "Row" TO GetProperty( "WinSelec", "Row" )
   SET SECTION "WinSelec" ENTRY "Col" TO GetProperty( "WinSelec", "Col" )
   SET SECTION "WinSelec" ENTRY "Width" TO GetProperty( "WinSelec", "Width" )
   SET SECTION "WinSelec" ENTRY "Height" TO GetProperty( "WinSelec", "Height" )

   SET SECTION "PInspector" ENTRY "Row" TO GetProperty( "PropInspector", "Row" )
   SET SECTION "PInspector" ENTRY "Col" TO GetProperty( "PropInspector", "Col" )
   SET SECTION "PInspector" ENTRY "Width" TO GetProperty( "PropInspector", "Width" )
   SET SECTION "PInspector" ENTRY "Height" TO GetProperty( "PropInspector", "Height" )

   SET SECTION "Recent" ENTRY "Windows" TO Len( ::RecentWindows )
   FOR nCount := 1 TO Len( ::RecentWindows )
      cEntry := "Win_" + AllTrim( Str( nCount ) )
      SET SECTION "Recent" ENTRY cEntry TO ::RecentWindows[ nCount ]
   NEXT

   END INI

RETURN NIL


METHOD SetWinsProps() CLASS gLayout

   OIWin.Row    := ::OSRow
   OIWin.Col    := ::OSCol
   OIWin.Width  := ::OSWidth
   OIWin.Height := ::OSHeight

// OIWin.OIGrid.Height := ::OSHeight
// MsgBox( STR(::OSHeight) )

   WinSelec.Row    := ::WSRow
   WinSelec.Col    := ::WSCol
   WinSelec.Width  := ::WSWidth
   WinSelec.Height := ::WSHeight

// WinSelec.WSGrid.Height := ::WSHeight - 10

   PropInspector.Row    := ::PIRow
   PropInspector.Col    := ::PICol
   PropInspector.Width  := ::PIWidth
   PropInspector.Height := ::PIHeight

// PropInspector.PropGrid.Height := ::PIHeight - 10

RETURN NIL


METHOD AddRecentWindow( cFileName ) CLASS gLayout

   IF Len( ::RecentWindows ) == G_MAX_RECENT
      ADel( ::RecentWindows, 1 )
      ::RecentWindows[ G_MAX_RECENT ] := cFileName
   ELSE
      AAdd( ::RecentWindows, cFileName )
   ENDIF
   MainMenu()

RETURN NIL


METHOD ChooseRecent() CLASS gLayout

   LOCAL nCount

   IF Empty( ::RecentWindows )
      ITEM "(No recently saved windows)"
   ELSE
      FOR nCount := 1 TO Len( ::RecentWindows )
         ITEM ::RecentWindows[ nCOunt ]
// ITEM ::RecentWindows[ nCOunt ] ACTION { || gTextEditor():New() }
      NEXT

   ENDIF

RETURN NIL
