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

CREATE CLASS gImage INHERIT gControl

   DATA PICTURE               INIT "GUIDES"
   DATA Action                INIT ""
   DATA OnDblClick            INIT ""
   DATA Transparent           INIT FALSE
   DATA STRETCH               INIT FALSE
   DATA ADJUST                INIT FALSE

   METHOD SetMainVars()  VIRTUAL
   METHOD Define()
   METHOD Code( oCode )
   METHOD Update()

END CLASS


METHOD Define() CLASS gImage

   @ ::Row, ::Col IMAGE &( ::Name ) OF &( ::oParen:Name ) ;
      PICTURE "GUIDESMINI" ;
      WIDTH ::Width HEIGHT ::Height

RETURN Self


METHOD Code( oCode ) CLASS gImage

   ::Super:Code( oCode )

   oCode:AddQuoted( "PICTURE", ::PICTURE )
   oCode:AddNotEmpty( "ACTION", ::Action )
   oCode:AddTag( "WIDTH", ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   oCode:AddNotEmpty( "HELPID", ::HelpID )
   oCode:AddNotEmpty( "INVISIBLE", ::Invisible )
   oCode:AddNotEmpty( "TRANSPARENT", ::Transparent )
   oCode:AddNotEmpty( "STRETCH", ::STRETCH )
   oCode:AddNotEmpty( "ADJUST", ::ADJUST )
   oCode:AddNotEmpty( "ON DBLCLICK",  ::OnDblClick )

   oCode:WriteToFile()

RETURN NIL


METHOD Update() CLASS gImage

   SetProperty( ::oParen:Name, ::Name, "Picture", ::PICTURE )
   ::Super:Update()

RETURN NIL
