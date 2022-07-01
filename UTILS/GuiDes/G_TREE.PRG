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

CREATE CLASS gTree INHERIT gControl

   DATA Value                 INIT 0
   DATA OnGotFocus            INIT ""
   DATA OnChange              INIT ""
   DATA OnLostFocus           INIT ""
   DATA OnDblClick            INIT ""
   DATA Elements              INIT {}
   DATA Break                 INIT FALSE

   METHOD SetMainVars()  VIRTUAL
   METHOD Define()
   METHOD Code( oCode )
   METHOD CodeElements( oCode )

END CLASS


METHOD Define() CLASS gTree

   DEFINE TREE &( ::Name ) ;
      OF &( ::oParen:Name ) ;
      AT ::Row, ::Col ;
      WIDTH ::Width HEIGHT ::Height ;
      FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
      TOOLTIP ::ToolTip ;
      ON GOTFOCUS {|| ::OnFocussed() }

   NODE "These are"

   TREEITEM "NOT user-defined"
   TREEITEM "nodes."

   NODE "These nodes are just"

   TREEITEM "for viewing"
   TREEITEM "tree appearance"

   END NODE

   END TREE

RETURN Self


METHOD Code( oCode ) CLASS gTree

   LOCAL cCode

   oCode:AddTag( "DEFINE TREE", ::ID, TRUE )
   IF oStyle:CodeIncludeParent()
      oCode:AddTag( "OF", ::oParen:Name )
   ENDIF

   cCode := AllTrim( Str( ::Row ) ) + "," + AllTrim( Str( ::Col ) )

   oCode:AddTag( "AT", cCode )
   oCode:AddTag( "WIDTH", ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   oCode:AddNotEmpty( "VALUE", ::Value )
   ::Super:FontCode( oCode )
   oCode:AddNotEmptyQuoted( "TOOLTIP", ::ToolTip )
   oCode:AddNotEmpty( "ON GOTFOCUS",  ::OnGotFocus )
   oCode:AddNotEmpty( "ON CHANGE",    ::OnChange )
   oCode:AddNotEmpty( "ON LOSTFOCUS", ::OnLostFocus )
   oCode:AddNotEmpty( "ON DBLCLICK",  ::OnDblClick )
   oCode:AddNotEmpty( "BREAK", ::Break )

   IF !Empty( ::Elements )
      ::CodeElements ( oCode )
   ENDIF

   oCode:AddTag( "END TREE", "", TRUE )

   oCode:WriteToFile()

RETURN NIL


METHOD CodeElements( oCode )

   LOCAL nCount, lCount
   LOCAL nLevel
   LOCAL Nextlevel

   oCode:MoreTab()
   FOR nCount := 1 TO Len( ::Elements )
      NextLevel := iif( nCount == Len( ::Elements ), 0, ::Elements[ nCount + 1 ][ 1 ] )
      nLevel := ::Elements[ nCount ][ 1 ]

      IF NextLevel > nLevel
         oCode:AddQuoted( "NODE", ::Elements[ nCount ][ 2 ], TRUE, TRUE )
         oCode:AddNotEmpty( "IMAGES", ::Elements[ nCount ][ 3 ], , )
         oCode:AddNotEmpty( "ID", ::Elements[ nCount ][ 4 ],  , )
         oCode:MoreTab()
      ELSE
         oCode:AddQuoted( "TREEITEM", ::Elements[ nCount ][ 2 ], TRUE, TRUE )
         oCode:AddNotEmpty( "IMAGES", ::Elements[ nCount ][ 3 ],  , )
         oCode:AddNotEmpty( "ID", ::Elements[ nCount ][ 4 ],  ,   )

         FOR lCount := 1 TO ( nLevel - NextLevel )
            oCode:LessTab()
            oCode:AddTag( "END NODE", , TRUE, , TRUE )
         NEXT

      ENDIF
   NEXT
   oCode:LessTab()

RETURN NIL
