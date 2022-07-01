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

CREATE CLASS gBrowse INHERIT gControl

   DATA Headers               INIT '{ "First Name", "Last Name" }'
   DATA Widths                INIT "{ 80, 80 }"
   DATA Workarea              INIT "SAMPDB"
   DATA FIELDS                INIT '{ "FIRST_NAME", "FAMILY_NAM" }'
   DATA Value                 INIT 0

   DATA On_GotFocus           INIT ""
   DATA On_Change             INIT ""
   DATA On_LostFocus          INIT ""
   DATA On_DblClick           INIT ""
   DATA Edit                  INIT FALSE
   DATA Inline                INIT FALSE
   DATA APPEND                INIT FALSE
   DATA On_HeadClick          INIT ""
   DATA VALID                 INIT ""
   DATA ValidMessages         INIT ""
   DATA READONLY              INIT ""
   DATA Lock                  INIT TRUE
   DATA DELETE                INIT FALSE
   DATA NoLines               INIT FALSE
   DATA Image                 INIT ""
   DATA Justify               INIT ""
   DATA NoVScroll             INIT FALSE
   DATA Break                 INIT FALSE

   METHOD SetMainVars()  VIRTUAL
   METHOD Define()
   METHOD Code( oCode )

END CLASS


METHOD Define() CLASS gBrowse

   IF Empty( Select( "SAMPDB" ) )
      IF !( File( GuiDesDir + "\SAMPLE.DBF" ) )
         CreateSampDB()
      ENDIF
      USE SAMPLE.DBF ALIAS SAMPDB SHARED NEW
   ENDIF

   @ ::Row, ::Col BROWSE &( ::Name ) OF &( ::oParen:Name ) ;
      WIDTH ::Width HEIGHT ::Height ;
      HEADERS { "First Name", "Last Name" } ;
      WIDTHS { 80, 80 } ;
      WORKAREA SAMPDB ;
      FIELDS { "FIRST_NAME", "FAMILY_NAM" } ;
      FONT ::Font[ 1 ] SIZE ::Font[ 2 ] ;
      TOOLTIP ::ToolTip ;
      ON GOTFOCUS {|| ::OnFocussed() }

RETURN Self


METHOD Code( oCode ) CLASS gBrowse

   ::Super:Code( oCode )

   oCode:AddTag( "WIDTH", ::Width )
   oCode:AddTag( "HEIGHT", ::Height )
   oCode:AddTag( "HEADERS", ::Headers )
   oCode:AddTag( "WIDTHS",  ::Widths )
   oCode:AddTag( "WORKAREA",  ::Workarea )
   oCode:AddTag( "FIELDS",  ::FIELDS )
   oCode:AddNotEmpty( "VALUE", ::Value )
   ::Super:FontCode( oCode )
   oCode:AddNotEmptyQuoted( "TOOLTIP", ::ToolTip )
   oCode:AddNotEmpty( "ON GOTFOCUS",  ::On_GotFocus )
   oCode:AddNotEmpty( "ON CHANGE",    ::On_Change )
   oCode:AddNotEmpty( "ON LOSTFOCUS", ::On_LostFocus )
   IF ::Edit
      IF ::Inline
         oCode:AddTag( "EDIT INPLACE" )
      ELSE
         oCode:AddTag( "EDIT" )
      ENDIF
      oCode:AddNotEmpty( "LOCK", ::Lock )
   ELSE
      oCode:AddNotEmpty( "ON DBLCLICK",  ::On_DblClick )
   ENDIF
   oCode:AddNotEmpty( "ON HEADCLICK", ::On_HeadClick )
   oCode:AddNotEmpty( "VALID", ::VALID )
   oCode:AddNotEmpty( "VALIDMESSAGES", ::ValidMessages )
   oCode:AddNotEmpty( "READONLY", ::READONLY )
   oCode:AddNotEmpty( "DELETE", ::DELETE )
   oCode:AddNotEmpty( "NOLINES", ::NoLines )
   oCode:AddNotEmpty( "IMAGE", ::Image )
   oCode:AddNotEmpty( "JUSTIFY", ::Justify )
   oCode:AddNotEmpty( "NOVSCROLL", ::NoVScroll )
   oCode:AddNotEmpty( "HELPID", ::HelpID )
   oCode:AddNotEmpty( "BREAK", ::Break )

   oCode:WriteToFile()

RETURN NIL
