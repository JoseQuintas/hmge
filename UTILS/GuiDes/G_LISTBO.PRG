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

CREATE CLASS gListBox INHERIT gControl

   DATA Items                 INIT ""
   DATA Value                 INIT 0
   DATA OnGotFocus            INIT ""
   DATA OnChange              INIT ""
   DATA OnLostFocus           INIT ""
   DATA OnDblClick            INIT ""
   DATA MultiSelect           INIT FALSE
   DATA Break                 INIT FALSE
   DATA NoTabStop             INIT FALSE
   DATA SORT                  INIT FALSE

   METHOD SetMainVars()
   METHOD Define()
   METHOD Code( oCode )

END CLASS


METHOD SetMainVars() CLASS gListBox

   ::Items := '{"' + ::Name + '_1", "' + ::Name + '_2", "' + ::Name + '_3" }'

RETURN Self


METHOD Define() CLASS gListBox

   @ ::Row, ::Col LISTBOX &( ::Name ) OF &( ::oParen:Name ) ;
      WIDTH ::Width  HEIGHT ::Height ;
      ITEMS &( '{"' + ::Name + '_1", "' + ::Name + '_2", "' + ::Name + '_3" }' ) ;
      FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
      TOOLTIP ::ToolTip ;
      ON GOTFOCUS {|| ::OnFocussed() }

RETURN Self



METHOD Code( oCode ) CLASS gListBox

   ::Super:Code( oCode )

   oCode:AddTag( "WIDTH",  ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   oCode:AddTag( "ITEMS",  ::Items )
   oCode:AddTag( "VALUE",  ::Value )
   ::Super:FontCode( oCode )
   oCode:AddNotEmptyQuoted( "TOOLTIP", ::ToolTip )
   oCode:AddNotEmpty( "ON GOTFOCUS",  ::OnGotFocus )
   oCode:AddNotEmpty( "ON CHANGE",    ::OnChange )
   oCode:AddNotEmpty( "ON LOSTFOCUS", ::OnLostFocus )
   oCode:AddNotEmpty( "ON DBLCLICK",  ::OnDblClick )
   oCode:AddNotEmpty( "MULTISELECT",  ::MultiSelect )
   oCode:AddNotEmpty( "HELPID", ::HelpID )
   oCode:AddNotEmpty( "BREAK", ::Break )
   oCode:AddNotEmpty( "INVISIBLE", ::Invisible )
   oCode:AddNotEmpty( "NOTABSTOP", ::NoTabStop )
   oCode:AddNotEmpty( "SORT", ::SORT )

   oCode:WriteToFile()

RETURN NIL
