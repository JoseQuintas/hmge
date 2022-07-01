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

CREATE CLASS gFrame INHERIT gControl

   DATA CAPTION             INIT ""
   DATA Opaque              INIT FALSE

   METHOD SetMainVars()
   METHOD Define()
   METHOD Code( oCode )
   METHOD Update()

END CLASS


METHOD SetMainVars() CLASS gFrame

   ::CAPTION := ::Name

RETURN Self


METHOD Define() CLASS gFrame

   @ ::Row, ::Col FRAME &( ::Name ) OF &( ::oParen:Name ) ;
      CAPTION ::CAPTION ;
      WIDTH ::Width HEIGHT ::Height ;
      FONT ::Font[ 1 ] SIZE ::Font[ 2 ]

RETURN Self


METHOD Code( oCode ) CLASS gFrame

   ::Super:Code( oCode )

   oCode:AddNotEmptyQuoted( "CAPTION", ::CAPTION )
   oCode:AddTag( "WIDTH", ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   ::Super:FontCode( oCode )
   oCode:AddNotEmpty( "OPAQUE",  ::Opaque )

   oCode:WriteToFile()

RETURN NIL


METHOD Update() CLASS gFrame

   SetProperty( ::oParen:Name, ::Name, "Caption", ::CAPTION )
   ::Super:Update()

RETURN NIL
