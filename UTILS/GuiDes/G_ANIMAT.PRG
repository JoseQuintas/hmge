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

CREATE CLASS gAnimateBox INHERIT gControl

   DATA Filename        INIT ""
   DATA Autoplay        INIT FALSE
   DATA Center          INIT FALSE
   DATA Transparent     INIT FALSE

   METHOD SetMainVars() VIRTUAL
   METHOD Define()
   METHOD Code( oCode )

END CLASS


METHOD Define() CLASS gAnimateBox

   @ ::Row, ::Col ANIMATEBOX &( ::Name ) OF &( ::oParen:Name ) ;
      WIDTH ::Width ;
      HEIGHT ::Height

RETURN Self


METHOD Code( oCode ) CLASS gAnimateBox

   ::Super:Code( oCode )

   oCode:AddTag( "WIDTH", ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   oCode:AddQuoted( "FILE", ::FileName )

   oCode:AddNotEmpty( "AUTOPLAY", ::Autoplay )
   oCode:AddNotEmpty( "CENTER", ::Center )
   oCode:AddNotEmpty( "TRANSPARENT", ::Transparent )
   oCode:AddNotEmpty( "HELPID", ::HelpID )

   oCode:WriteToFile()

RETURN NIL
