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

CREATE CLASS gProgressBar INHERIT gControl

   DATA RangeMin              INIT 0
   DATA RangeMax              INIT 100
   DATA Value                 INIT 0
   DATA Vertical              INIT FALSE
   DATA Smooth                INIT FALSE

   METHOD SetMainVars()  VIRTUAL
   METHOD Define()
   METHOD Code( oCode )

END CLASS


METHOD Define() CLASS gProgressBar

   @ ::Row, ::Col PROGRESSBAR &( ::Name ) OF &( ::oParen:Name ) ;
      RANGE ::RangeMin, ::RangeMax ;
      WIDTH ::Width ;
      HEIGHT ::Height ;
      TOOLTIP ::ToolTip

   SetProperty( ::oParen:Name, ::Name, "Value", 70 )

RETURN Self


METHOD Code( oCode ) CLASS gProgressBar

   LOCAL cCode := AllTrim( Str( ::RangeMin ) ) + " , " + AllTrim( Str( ::RangeMax ) )

   ::Super:Code( oCode )

   oCode:AddTag( "RANGE", cCode )
   oCode:AddTag( "WIDTH",  ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   oCode:AddTag( "VALUE", ::Value )
   oCode:AddNotEmptyQuoted( "TOOLTIP", ::ToolTip )
   oCode:AddNotEmpty( "VERTICAL", ::Vertical )
   oCode:AddNotEmpty( "SMOOTH", ::Smooth )
   oCode:AddNotEmpty( "HELPID", ::HelpID )

   oCode:WriteToFile()

RETURN NIL
