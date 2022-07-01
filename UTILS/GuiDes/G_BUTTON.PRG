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

CREATE CLASS gButton INHERIT gControl

   DATA HasPicture            INIT FALSE
   DATA CAPTION               INIT ""
   DATA PictureName           INIT ""
   DATA Action                INIT "{ || NIL }"
   DATA Flat                  INIT FALSE
   DATA NoTabStop             INIT FALSE

   DATA OnGotFocus            INIT ""
   DATA OnLostFocus           INIT ""
   DATA Transparent  INIT FALSE

   METHOD SetMainVars()
   METHOD Define()
   METHOD Code( oCode )
   METHOD Update()

END CLASS


METHOD SetMainVars() CLASS gButton

   ::CAPTION      := ::Name

RETURN Self


METHOD Define() CLASS gButton

   @ ::Row, ::Col BUTTON &( ::Name ) OF &( ::oParen:Name ) CAPTION ( ::Caption ) ;
      ACTION ::Action ;
      WIDTH ::Width HEIGHT ::Height ;
      FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
      TOOLTIP ::ToolTip ;
      ON GOTFOCUS {|| ::OnFocussed() }

RETURN Self


METHOD Code( oCode ) CLASS gButton

   ::Super:Code( oCode )

   IF ::HasPicture
      oCode:AddTag( "PICTURE", ::PictureName )
      oCode:AddTag( "ACTION", ::Action )
      oCode:AddTag( "WIDTH", ::Width )
      oCode:AddTag( "HEIGHT", ::Height )
   ELSE
      oCode:AddQuoted( "CAPTION", ::CAPTION )
      oCode:AddTag( "ACTION", ::Action )
      oCode:AddTag( "WIDTH", ::Width )
      oCode:AddTag( "HEIGHT", ::Height )
      ::Super:FontCode( oCode )
   ENDIF

   oCode:AddNotEmptyQuoted( "TOOLTIP", ::ToolTip )

   IF ::Flat
      oCode:AddLine( "FLAT" )
   ENDIF

   IF ::HasPicture
      oCode:AddNotEmpty( "TRANSPARENT", ::Transparent )
   ENDIF

   oCode:AddNotEmpty( "ON GOTFOCUS",  ::OnGotFocus )
   oCode:AddNotEmpty( "ON LOSTFOCUS", ::OnLostFocus )
   oCode:AddNotEmpty( "NOTABSTOP", ::NoTabStop )
   oCode:AddNotEmpty( "HELPID", ::HelpID )
   oCode:AddNotEmpty( "INVISIBLE", ::Invisible )

   oCode:WriteToFile()

RETURN NIL


METHOD Update() CLASS gButton

   SetProperty( ::oParen:Name, ::Name, "Caption", ::CAPTION )
   ::Super:Update()

RETURN NIL
