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

CREATE CLASS gLabel INHERIT gControl

   DATA Value        INIT ""
   DATA BackColor    INIT G_GREY
   DATA FontColor    INIT G_BLACK
   DATA Bold         INIT FALSE
   DATA Transparent  INIT FALSE
   DATA RightAlign   INIT FALSE
   DATA CenterAlign  INIT FALSE
   DATA VCenterAlign INIT FALSE

   DATA Action       INIT ""

   METHOD SetMainVars()
   METHOD Define()
   METHOD Code( oCode )
   METHOD Update()

END CLASS


METHOD SetMainVars() CLASS gLabel

   ::Value := ::Name
   ::BackColor    := oStyle:BackColor
   ::FontColor    := oStyle:FontColor

RETURN Self


METHOD Define() CLASS gLabel

   IF oStyle:AutoSize()
      @ ::Row, ::Col LABEL &( ::Name ) OF &( ::oParen:Name ) ;
         VALUE ::Value ;
         AUTOSIZE ;
         FONT ::Font[ 1 ] SIZE ::Font[ 2 ]

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
      @ ::Row, ::Col LABEL &( ::Name ) OF &( ::oParen:Name ) ;
         VALUE ::Value ;
         WIDTH ::Width HEIGHT ::Height ;
         FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
         BACKCOLOR ::BackColor ;
         FONTCOLOR ::FontColor

   ENDIF

   IF ::RightAlign
      SetProperty( ::oParen:Name, ::Name, "Alignment", "Right" )
   ELSEIF ::CenterAlign
      SetProperty( ::oParen:Name, ::Name, "Alignment", "Center" )
   ENDIF

   IF ::VCenterAlign
      SetProperty( ::oParen:Name, ::Name, "Alignment", "VCenter" )
   ENDIF

RETURN Self



METHOD Code( oCode ) CLASS gLabel

   ::Super:Code( oCode )

   oCode:AddQuoted( "VALUE",  ::Value )
   oCode:AddNotEmpty( "ACTION", ::Action )
   oCode:AddTag( "WIDTH",  ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   ::Super:FontCode( oCode )
   oCode:AddTag( "BACKCOLOR", ColorToCode( ::BackColor ) )
   oCode:AddTag( "FONTCOLOR", ColorToCode( ::FontColor ) )
   oCode:AddNotEmpty( "BOLD", ::Bold )
   oCode:AddNotEmpty( "TRANSPARENT", ::Transparent )
   oCode:AddNotEmpty( "RIGHTALIGN", ::RightAlign )
   oCode:AddNotEmpty( "CENTERALIGN", ::CenterAlign )
   oCode:AddNotEmpty( "VCENTERALIGN", ::VCenterAlign )
   oCode:AddNotEmpty( "HELPID", ::HelpID )
   oCode:AddNotEmpty( "INVISIBLE", ::Invisible )

   oCode:WriteToFile()

RETURN NIL


METHOD Update() CLASS gLabel

   SetProperty( ::oParen:Name, ::Name, "Value", ::Value )
   SetProperty( ::oParen:Name, ::Name, "Backcolor", ::BackColor )
   SetProperty( ::oParen:Name, ::Name, "FontColor", ::FontColor )

   IF ::RightAlign
      SetProperty( ::oParen:Name, ::Name, "Alignment", "Right" )
   ELSEIF ::CenterAlign
      SetProperty( ::oParen:Name, ::Name, "Alignment", "Center" )
   ELSE
      SetProperty( ::oParen:Name, ::Name, "Alignment", "Left" )
   ENDIF

   IF ::VCenterAlign
      SetProperty( ::oParen:Name, ::Name, "Alignment", "VCenter" )
   ELSE
      ChangeStyle( GetControlHandle( ::Name, ::oParen:Name ), , 512 /*SS_CENTERIMAGE*/ )
   ENDIF

   ::Super:Update()

RETURN NIL
