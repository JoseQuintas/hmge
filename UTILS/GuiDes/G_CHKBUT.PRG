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

CREATE CLASS gCheckButton INHERIT gControl

   DATA HasPicture            INIT FALSE
   DATA CAPTION               INIT ""
   DATA Flat                  INIT FALSE
   DATA PictureName  INIT ""
   DATA Value         INIT FALSE

   DATA OnGotFocus            INIT ""
   DATA OnChange              INIT ""
   DATA OnLostFocus           INIT ""

   METHOD SetMainVars()
   METHOD Define()
   METHOD Code( oCode )
   METHOD Update()

END CLASS


METHOD SetMainVars() CLASS gCheckButton

   ::CAPTION      := ::Name

RETURN Self


METHOD Define() CLASS gCheckButton

   @ ::Row, ::Col CHECKBUTTON &( ::Name ) OF &( ::oParen:Name ) ;
      CAPTION ( ::Caption ) ;
      WIDTH ::Width HEIGHT ::Height ;
      FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
      TOOLTIP ::ToolTip ;
      ON GOTFOCUS {|| ::OnFocussed() }

RETURN Self



METHOD Code( oCode ) CLASS gCheckButton

   ::Super:Code( oCode )

   IF ::HasPicture
      oCode:AddTag( "PICTURE", ::PictureName )
   ELSE
      oCode:AddQuoted( "CAPTION", ::CAPTION )
   ENDIF
   oCode:AddTag( "WIDTH", ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   oCode:AddTag( "VALUE", ::Value )
   IF !( ::HasPicture )
      ::Super:FontCode( oCode )
   ENDIF
   oCode:AddNotEmptyQuoted( "TOOLTIP", ::ToolTip )
   IF ::Flat
      oCode:AddLine( "FLAT" )
   ENDIF
   oCode:AddNotEmpty( "ON GOTFOCUS",  ::OnGotFocus )
   oCode:AddNotEmpty( "ON CHANGE",  ::OnChange )
   oCode:AddNotEmpty( "ON LOSTFOCUS", ::OnLostFocus )
   oCode:AddNotEmpty( "HELPID", ::HelpId )
   oCode:AddNotEmpty( "INVISIBLE", ::Invisible )

   oCode:WriteToFile()

RETURN NIL


METHOD Update() CLASS gCheckButton

   SetProperty( ::oParen:Name, ::Name, "Caption", ::CAPTION )
   ::Super:Update()

RETURN NIL
