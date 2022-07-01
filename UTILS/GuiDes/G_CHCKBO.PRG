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

CREATE CLASS gCheckBox INHERIT gControl

   DATA CAPTION               INIT ""
   DATA Value                 INIT FALSE

   DATA FieldName             INIT ""
   DATA OnGotfocus            INIT ""
   DATA OnLostfocus           INIT ""
   DATA OnChange              INIT ""
   DATA Backcolor             INIT G_GREY
   DATA Fontcolor             INIT G_BLACK
   DATA Transparent           INIT FALSE

   METHOD SetMainVars()
   METHOD Define()
   METHOD Code( oCode )
   METHOD Update()

END CLASS


METHOD SetMainVars() CLASS gCheckBox

   ::CAPTION      := ::Name
   ::BackColor    := oStyle:BackColor
   ::FontColor    := oStyle:FontColor

RETURN Self


METHOD Define() CLASS gCheckBox

   IF oStyle:AutoSize()
      @ ::Row, ::Col CHECKBOX &( ::Name ) OF &( ::oParen:Name ) ;
         CAPTION ( ::Caption ) ;
         AUTOSIZE ;
         FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
         TOOLTIP ::ToolTip ;

      IF Empty( ::BackColor )
         ::BackColor := GetProperty( ::oParen:Name, ::Name, "BackColor" )
      ELSE
         SetProperty( ::oParen:Name, ::Name, "BackColor", ::BackColor )
      ENDIF

      IF Empty( ::FontColor )
         ::FontColor := GetProperty( ::oParen:Name, ::Name, "FontColor" )
      ELSE
         SetProperty( ::oParen:Name, ::Name, "FontColor", ::FontColor )
      ENDIF

      ::Width  := GetProperty( ::oParen:Name, ::Name, "Width" )
      ::Height := GetProperty( ::oParen:Name, ::Name, "Height" )

   ELSE
      @ ::Row, ::Col CHECKBOX &( ::Name ) OF &( ::oParen:Name ) ;
         CAPTION ( ::Caption ) ;
         WIDTH ::Width HEIGHT ::Height ;
         FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
         TOOLTIP ::ToolTip ;
         BACKCOLOR ::BackColor ;
         FONTCOLOR ::FontColor ;
         ON GOTFOCUS {|| ::OnFocussed() }

   ENDIF

RETURN Self



METHOD Code( oCode ) CLASS gCheckBox

   ::Super:Code( oCode )

   oCode:AddQuoted( "CAPTION", ::CAPTION )
   oCode:AddTag( "WIDTH", ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   oCode:AddTag( "VALUE", ::Value )
   oCode:AddNotEmpty( "FIELD",  ::FieldName )
   ::Super:FontCode( oCode )
   oCode:AddNotEmptyQuoted( "TOOLTIP", ::ToolTip )
   oCode:AddTag( "BACKCOLOR", ColorToCode( ::BackColor ) )
   oCode:AddTag( "FONTCOLOR", ColorToCode( ::FontColor ) )
   oCode:AddNotEmpty( "ON GOTFOCUS",  ::OnGotFocus )
   oCode:AddNotEmpty( "ON CHANGE", ::OnChange )
   oCode:AddNotEmpty( "ON LOSTFOCUS", ::OnLostFocus )
   oCode:AddNotEmpty( "TRANSPARENT", ::Transparent )
   oCode:AddNotEmpty( "HELPID", ::HelpId )
   oCode:AddNotEmpty( "INVISIBLE", ::Invisible )

   oCode:WriteToFile()

RETURN NIL


METHOD Update() CLASS gCheckBox

   SetProperty( ::oParen:Name, ::Name, "Caption", ::CAPTION )
   SetProperty( ::oParen:Name, ::Name, "Backcolor", ::BackColor )
   SetProperty( ::oParen:Name, ::Name, "FontColor", ::FontColor )
   ::Super:Update()

RETURN NIL
