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

CREATE CLASS gGrid INHERIT gControl

   DATA Headers               INIT '{ "Header 1", "Header 2" }'
   DATA Widths                INIT '{ 100, 100 }'
   DATA Items                 INIT '{ { "Data 1", "Data 2" }, { "Data 3", "Data 4" } }'
   DATA Value                 INIT 0
   DATA OnGotFocus            INIT ""
   DATA OnChange              INIT ""
   DATA OnLostFocus           INIT ""
   DATA OnDblClick            INIT ""
   DATA OnHeadClick           INIT ""
   DATA HeadClick             INIT ""
   DATA Edit                  INIT FALSE
   DATA CellNavigation        INIT FALSE
   DATA Multiselect           INIT FALSE
   DATA NoLines               INIT FALSE
   DATA Image                 INIT ""
   DATA Justify               INIT ""
   DATA Break                 INIT FALSE

   METHOD SetMainVars()  VIRTUAL
   METHOD Define()
   METHOD Code( oCode )

END CLASS


METHOD Define() CLASS gGrid

   @ ::Row, ::Col GRID &( ::Name ) OF &( ::oParen:Name ) ;
      WIDTH ::Width HEIGHT ::Height ;
      HEADERS { "Header 1", "Header 2" } ;
      WIDTHS { 100, 100 } ;
      ITEMS { { "Data 1", "Data 2" }, { "Data 3", "Data 4" } } ;
      FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
      TOOLTIP ::ToolTip ;
      ON GOTFOCUS {|| ::OnFocussed() }

RETURN Self


METHOD Code( oCode ) CLASS gGrid

   ::Super:Code( oCode )

   oCode:AddTag( "WIDTH", ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   oCode:AddTag( "HEADERS", ::Headers )
   oCode:AddTag( "WIDTHS",  ::Widths )
   oCode:AddNotEmpty( "ITEMS", ::Items )
   oCode:AddNotEmpty( "EDIT", ::Edit )
   oCode:AddNotEmpty( "CELLNAVIGATION", ::CellNavigation )
   oCode:AddNotEmpty( "VALUE", ::Value )
   ::Super:FontCode( oCode )
   oCode:AddNotEmptyQuoted( "TOOLTIP", ::ToolTip )
   oCode:AddNotEmpty( "ON GOTFOCUS",  ::OnGotFocus )
   oCode:AddNotEmpty( "ON CHANGE",    ::OnChange )
   oCode:AddNotEmpty( "ON LOSTFOCUS", ::OnLostFocus )
   oCode:AddNotEmpty( "ON DBLCLICK",  ::OnDblClick )
   oCode:AddNotEmpty( "ON HEADCLICK", ::OnHeadClick )
   oCode:AddNotEmpty( "MULTISELECT",   ::Multiselect )
   oCode:AddNotEmpty( "NOLINES", ::NoLines )
   oCode:AddNotEmpty( "IMAGE", ::Image )
   oCode:AddNotEmpty( "JUSTIFY", ::Justify )
   oCode:AddNotEmpty( "HELPID", ::HelpID )
   oCode:AddNotEmpty( "BREAK", ::Break )

   oCode:WriteToFile()

RETURN NIL
