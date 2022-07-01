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

CREATE CLASS gTab INHERIT gControl

   DATA nPage                 INIT 0
   DATA Value                 INIT 1
   DATA BOTTOM                INIT FALSE
   DATA MULTILINE             INIT FALSE
   DATA NoTabStop             INIT FALSE
   DATA OnChange              INIT ""
   DATA BackColor             INIT G_LIGHTGREY

   METHOD SetMainVars()
   METHOD Define()
   METHOD Code( oCode )
   METHOD Update()
   METHOD AddNewPage()
   METHOD DeletePage()

END CLASS


METHOD SetMainVars() CLASS gTab

   ::Width        := GetProperty( ::oParen:Name, "Width" ) - 50
   ::Height       := GetProperty( ::oParen:Name, "Height" ) - 50 - GetTitleHeight() - GetProperty( ::oParen:Name, "StatusBar", "Height" )
   ::BackColor    := NIL

RETURN Self


METHOD Define() CLASS gTab

   LOCAL i

   IF !Empty( ::BackColor )
      IF ::BOTTOM
         DEFINE TAB &( ::Name ) OF &( ::oParen:Name ) ;
            AT ::Row, ::Col ;
            WIDTH  ::Width ;
            HEIGHT ::Height ;
            VALUE ::Value ;
            FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
            TOOLTIP ::ToolTip ;
            BACKCOLOR ::BackColor ;
            ON CHANGE ::AddNewPage() ;
            BOTTOM
      ELSE
         DEFINE TAB &( ::Name ) OF &( ::oParen:Name ) ;
            AT ::Row, ::Col ;
            WIDTH  ::Width ;
            HEIGHT ::Height ;
            VALUE ::Value ;
            FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
            TOOLTIP ::ToolTip ;
            BACKCOLOR ::BackColor ;
            ON CHANGE ::AddNewPage()
      ENDIF
   ELSE
      IF ::BOTTOM
         DEFINE TAB &( ::Name ) OF &( ::oParen:Name ) ;
            AT ::Row, ::Col ;
            WIDTH  ::Width ;
            HEIGHT ::Height ;
            VALUE ::Value ;
            FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
            TOOLTIP ::ToolTip ;
            ON CHANGE ::AddNewPage() ;
            BOTTOM
      ELSE
         DEFINE TAB &( ::Name ) OF &( ::oParen:Name ) ;
            AT ::Row, ::Col ;
            WIDTH  ::Width ;
            HEIGHT ::Height ;
            VALUE ::Value ;
            FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
            TOOLTIP ::ToolTip ;
            ON CHANGE ::AddNewPage()
      ENDIF
   ENDIF

   FOR i := 1 TO ::nPage
      IF i < ::nPage
         PAGE "Page " + hb_ntos( i )
      ELSE
         PAGE "Add+"
      ENDIF
      END PAGE
   NEXT

   END TAB

   DEFINE CONTEXT MENU CONTROL &( ::Name ) OF &( ::oParen:Name )
      MENUITEM "Delete Page" ACTION ::DeletePage()
   END MENU

   ::AddNewPage()

RETURN Self


METHOD Code( oCode ) CLASS gTab

   LOCAL cCode, i

   oCode:AddTag( "DEFINE TAB", ::ID, TRUE )
   IF oStyle:CodeIncludeParent()
      oCode:AddTag( "OF", ::oParen:Name )
   ENDIF

   cCode := AllTrim( Str( ::Row ) ) + "," + AllTrim( Str( ::Col ) )

   oCode:AddTag( "AT", cCode )
   oCode:AddTag( "WIDTH", ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   oCode:AddTag( "VALUE", ::Value )
   ::Super:FontCode( oCode )
   oCode:AddNotEmptyQuoted( "TOOLTIP", ::ToolTip )
   IF !Empty( ::BackColor )
      oCode:AddTag( "BACKCOLOR", ColorToCode( ::BackColor ) )
   ENDIF
   oCode:AddNotEmpty( "BOTTOM", ::BOTTOM )
   oCode:AddNotEmpty( "MULTILINE", ::MULTILINE )
   oCode:AddNotEmpty( "NOTABSTOP", ::NoTabStop )
   oCode:AddNotEmpty( "ON CHANGE", ::OnChange )

   FOR i := 1 TO ::nPage - 1
      oCode:AddTag( 'PAGE "Page ' + hb_ntos( i ) + '"', "", TRUE )
      oCode:AddTag( "END PAGE", "", TRUE )
   NEXT
   oCode:AddTag( "END TAB", "", TRUE )

   oCode:WriteToFile()

RETURN NIL


METHOD Update() CLASS gTab

   SetProperty( ::oParen:Name, ::Name, "Backcolor", ::BackColor )
   ::Super:Update()

RETURN NIL


METHOD AddNewPage() CLASS gTab

   IF ::nPage == 1
      DoMethod( ::oParen:Name, ::Name, "AddPage", ::nPage, "Page " + hb_ntos( ::nPage ) )
      ::nPage++
      SetProperty( ::oParen:Name, ::Name, "Value", ::nPage - 1 )
      Return nil
   ENDIF

   IF GetProperty( ::oParen:Name, ::Name, "Value" ) == ::nPage
      IF ::nPage >= 2
         DoMethod( ::oParen:Name, ::Name, "DeletePage", ::nPage )
         DoMethod( ::oParen:Name, ::Name, "AddPage", ::nPage, "Page " + hb_ntos( ::nPage ) )
         ::nPage++
         DoMethod( ::oParen:Name, ::Name, "AddPage", ::nPage, 'Add+', , 'Click over Add+ will add a new Page' )
         SetProperty( ::oParen:Name, ::Name, "Value", ::nPage - 1 )
      ELSE 
         ::nPage++
         DoMethod( ::oParen:Name, ::Name, "AddPage", ::nPage, "Page " + hb_ntos( ::nPage ) )
         ::nPage++
         DoMethod( ::oParen:Name, ::Name, "AddPage", ::nPage, 'Add+', , 'Click over Add+ will add a new Page' )
         SetProperty( ::oParen:Name, ::Name, "Value", ::nPage - 1 )
      ENDIF
   ENDIF

Return nil


METHOD DeletePage() CLASS gTab

   LOCAL nDeletePage

   nDeletePage := GetProperty( ::oParen:Name, ::Name, "Value" )

   IF nDeletePage == GetProperty( ::oParen:Name, ::Name, "ItemCount" ) - 1
      DoMethod( ::oParen:Name, ::Name, "DeletePage", nDeletePage )
      ::nPage--
      IF ::nPage == 1
         ::AddNewPage()
      ENDIF
   ELSE
      PlayHand()
   ENDIF

Return nil
